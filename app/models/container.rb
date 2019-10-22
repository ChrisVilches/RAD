class Container < ApplicationRecord
  has_many :elements

  has_many :numeric_inputs, through: :elements, source: :elementable, source_type: 'NumericInput'
  has_many :text_inputs, through: :elements, source: :elementable, source_type: 'TextInput'
  has_many :containers, through: :elements, source: :elementable, source_type: 'Container'

  belongs_to :view, optional: true

  validate :element_order_correct?
  validate :validate_recursively!

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

  private

  # This method validates recursively for all nested containers.
  # It also checks that all elements (including inputs, etc) have a correct
  # elementable.
  def validate_recursively!
    self.element_list.each do |e|
      if e.nil? || !e.valid?
        errors.add(:elements)
        return
      end
    end
  end

  # Validates that the elements don't have incorrect positions, such as
  # repeated positions, or skips from one position to another.
  def element_order_correct?
    elements = self.elements.sort_by{|e| e.position}
    elements.each_with_index do |e, i|
      if e.nil? || e.position != i
        errors.add(:elements)
        return
      end

    end
  end
end
