class Container < ApplicationRecord

  has_many :elements, dependent: :destroy

  belongs_to :inputable, polymorphic: true, optional: true

  validate :element_order_correct?
  validate :validate_recursively!
  validate :all_variable_names_are_unique?

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
      if e.nil? || !e.valid?
        errors.add(:elements, "nested subtree is invalid")
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
end
