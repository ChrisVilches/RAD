class Container < ApplicationRecord

  include FormComponent

  has_many :elements, dependent: :destroy

  belongs_to :inputable, polymorphic: true, optional: true

  validate :element_order_correct?
  validate :validate_recursively!
  validate :all_variable_names_are_unique?

  before_validation :remove_empty_container_subtrees!

  def self.configurable_params
    [:is_active]
  end

  # Used for getting the error structures for client screens,
  # ViewEdit and QueryEdit.
  # Errors that nested subtrees have in a container, won't count as an error,
  # and it won't be in the final output, however errors in the container itself
  # such as lack of variable_name will be in the output.
  # @return [Hash] Hash with a tree structure same as the form tree, but only containing error (boolean) information.
  def error_structure

    # Root node doesn't need to be validated. Because this is the Container
    # class, and not the Element class that contains it, it's impossible to validate
    # things like variable_name (since it belongs to Element).

    def traverse(node, root = false)
      raise "node arg should be an Element" unless node.is_a?(Element)
      if node.elementable.is_a?(Container)
        container = node.elementable
        elements = []
        container.elements.each do |e|
          elements << traverse(e)
        end

        container_valid = false

        # If it's the root, don't validate.
        if root
          container_valid = true
        else
          # Only validate THIS container isolated without picking up
          # errors recursively from its children.
          node.validate
          error_keys = container.errors.keys.uniq
          error_keys.delete :elements
          error_keys.delete :elements_recursive_subtree

          # After having processed the container errors (and removed the ones
          # that have to be ignored, add the node errors... here there might be
          # for example a variable_name error, etc)
          error_keys += node.errors.keys
          error_keys.uniq!
          container_valid = error_keys.empty?
        end

        # TODO this can be optimized so that only one "validate" is executed,
        # and for one part we ignore the elements_unique_variable_names, and for
        # the other one we do use it. But for now this works, it just does the
        # validation twice.

        # Validate again just to get the :elements_unique_variable_names (error)
        container.validate
        # Add errors to elements that have variable_name used in more than one place
        container.errors[:elements_unique_variable_names].each do |err|
          if err.is_a?(Hash) && err.has_key?(:index_repeated)
            idx = err[:index_repeated]
            elements[idx][:error] = true
          end
        end
        { error: !container_valid, elements: elements }
      else
        { error: !node.valid? }
      end
    end

    elem = Element.new elementable: self
    traverse(elem, true)
  end

  def to_debug_s

    def traverse(depth, container)
      return "" unless container.is_a?(Container)

      elements = container.elements.sort_by{|e| e.position}
      string = ""

      indent = ""
      depth.times do
        indent << "　"
      end

      if depth > 0
        indent << "└"
      end

      elements.each do |e|
        string << "#{indent}#{e.elementable.class} (element ID #{e.id} | elementable_id #{e.elementable_id}) | variable name #{e.variable_name}\n"
        string << traverse(depth+1, e.elementable)
      end
      string
    end

    ret = "Created #{self.created_at}\n"
    ret << "Updated #{self.updated_at}\n"
    ret << traverse(0, self)
    ret

  end

  # TODO Comment hash structure
  def self.build_from_hash(hash, d = 0)

    container = Container.new

    hash[:elements].each_with_index do |ele, idx|
      type = ele[:elementable_type]

      opts = ele[:params].nil? ? ActionController::Parameters.new : ele[:params]

      elementable = nil

      elementable = case type
      when "NumericInput"
        NumericInput.new(opts.permit(NumericInput.configurable_params))
      when "TextInput"
        TextInput.new(opts.permit(TextInput.configurable_params))
      when "OptionInput"
        OptionInput.new(opts.permit(OptionInput.configurable_params))
      when "Container"
        # Build recursively
        new_container = Container.build_from_hash(ele, d+1)
        new_container.attributes = opts.permit(Container.configurable_params)
        new_container
      else
        raise "Incorrect type: #{type}"
      end

      element = Element.new(
        variable_name: ele[:variable_name] || "variable-#{idx}",
        position: idx,
        elementable: elementable,
        label: ele[:label] || "Component label"
      )

      container.elements << element

    end

    container
  end


  # In case the design ever changes, this is a method that returns the list of
  # elements inside the container. If the database structure changes, then this method
  # must be changed, but without affecting the result.
  # TODO Should not be used? sometimes it's useful to know the Element properties as well.
  # @return [Array] List of Element
  def element_list
    list = []
    self.elements.each do |e|
      list << e.elementable
    end
    return list
  end

  def user_inputs_errors(user_inputs)

    elements_with_errors = Set.new

    user_inputs.each do |i|
      element = find_element_from_path(i[:path])
      element_errors = element.elementable.input_value_errors(i[:value])

      unless element_errors.empty?
        elements_with_errors << {
          # TODO
          # There's a huge problem here... if the developer user saves (even if he doesn't modify anything) the
          # forms while another user is executing it, the element IDs while change
          # and the client will get errors for different element IDs (the ID will get higher).
          # As a result, the client won't display the error.
          # An easy way to fix this is by having the client send the container ID or timestamp of
          # last update, and then compare it to the last update in the backend. If the client has an
          # outdated version, then tell the client he must refresh the page (or just refresh that container).
          # Warning: Ensure that the timestamp or version number only changes if the thing actually changes...
          # because updated_at gets modified by every single update, even if it doesn't update important data.
          id: element.id,
          path: i[:path],
          messages: element_errors
        }
      end
    end

    return elements_with_errors.to_a
  end

  private

  def find_element_from_path(path)
    curr = self
    if path.length > 1
      # Traversing containers.
      path[0..path.length-2].each do |p|
        curr = curr.elements.find {|e| e.variable_name == p}
        raise "Path is wrong" if curr.nil?
        curr = curr.elementable
        raise "Path element is not a container" unless curr.is_a?(Container)
      end
    end

    element = curr.elements.find {|e| e.variable_name == path.last}
    return element
  end

  # This method validates recursively for all nested containers.
  # It also checks that all elements (including inputs, etc) have a correct
  # elementable.
  def validate_recursively!

    self.elements.each do |e|
      if e.nil? || e.elementable.nil?
        errors.add(:elements, "has a nil element")
        return
      end

      if !e.valid?
        errors.add(:elements_recursive_subtree, "nested subtree is invalid (Details: #{e.errors.full_messages})")
        return
      end
    end
  end

  # Checks that all variable names are unique.
  def all_variable_names_are_unique?

    error_index = Array.new
    first_occurrences = Hash.new
    self.elements.each_with_index do |elem, idx|
      variable_name = elem.variable_name
      if first_occurrences.has_key?(variable_name)
        first_idx = first_occurrences[variable_name]
        # Add error to current idx and first occurrence
        error_index << idx
        error_index << first_idx
      else
        first_occurrences[variable_name] = idx
      end
    end

    unless error_index.empty?
      error_index.sort!
      error_index.uniq!
      error_index.each do |idx|
        errors.add(:elements_unique_variable_names, { :index_repeated => idx })
      end
    end
  end

  # Validates that the elements don't have incorrect positions, such as
  # repeated positions, or skips from one position to another.
  def element_order_correct?
    elements = self.elements.sort_by{|e| e.position}
    elements.each_with_index do |e, i|
      if e.nil? || e.position != i
        errors.add(:elements, "order is incorrect")
        return
      end
    end
  end

  def remove_empty_container_subtrees!
    # TODO removes unused containers
  end

  def valid_ignoring_nested_subtree?

  end
end
