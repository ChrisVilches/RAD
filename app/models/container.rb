class Container < ApplicationRecord

  has_many :elements, dependent: :destroy

  belongs_to :inputable, polymorphic: true, optional: true

  validate :element_order_correct?
  validate :validate_recursively!
  validate :all_variable_names_are_unique?

  before_validation :remove_empty_container_subtrees!

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
        string << "#{indent}#{e.elementable.class} (element ID #{e.id} | elementable_id #{e.elementable_id})\n"
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
        new_container.attributes = ele.permit(:is_active)
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
  # @return [Array] List of Element
  def element_list
    list = []
    self.elements.each do |e|
      list << e.elementable
    end
    return list
  end

  def user_inputs_errors(user_inputs)

    errors = Set.new

    user_inputs.each do |i|
      element = find_element_from_path(i[:path])
      valid_result = element.elementable.validate_input_value(i[:value])

      errors << i[:path] unless valid_result
    end

    return errors.to_a
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

    self.element_list.each do |e|
      if e.nil?
        errors.add(:elements, "has a nil element")
        return
      end

      if !e.valid?
        errors.add(:elements, "nested subtree is invalid (Details: #{e.errors.full_messages})")
        return
      end
    end
  end

  # Checks that all variable names are unique.
  def all_variable_names_are_unique?
    names = Set.new
    self.elements.each do |e|
      n = e.variable_name
      if names.include?(n)
        errors.add(:elements, "variable names are repeated")
        return
      else
        names << n
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

  end
end
