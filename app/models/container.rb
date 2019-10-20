class Container < ApplicationRecord
  has_many :elements

  has_many :numeric_inputs, through: :elements, source: :elementable, source_type: 'NumericInput'
  has_many :text_inputs, through: :elements, source: :elementable, source_type: 'TextInput'

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
end
