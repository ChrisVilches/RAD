class Input < ApplicationRecord

  include FormComponent

  has_one :element

  protected

  def input_value_errors(value)
    self.validate
    unless self.errors.blank?
      raise "Input is not valid. A value cannot be tested against it"
    end
  end
end
