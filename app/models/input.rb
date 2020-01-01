class Input < ApplicationRecord

  has_one :element

  def self.configurable_params
    raise NotImplementedError
  end

  protected

  def validate_input_value(value)
    self.validate
    unless self.errors.blank?
      raise "Input is not valid. A value cannot be tested against it"
    end
  end
end
