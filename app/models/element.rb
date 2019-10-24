class Element < ApplicationRecord
  belongs_to :elementable, :polymorphic => true
  belongs_to :container
  validates :elementable, presence: true
  validate :allowed_elementable_value?
  validate :correct_variable_name?

  before_validation :compute_position!
  before_validation :set_correct_elementable_type!

  private

  # TODO This should be automatic, but I cannot get the ORM to do it automatically.
  # The elementable_type column should be set with the specific class name, and
  # not Input.
  def set_correct_elementable_type!
    self.elementable_type = self.elementable.class.to_s
  end

  def allowed_elementable_value?
    allowed = [TextInput, NumericInput, OptionInput, Container]
    return allowed.map{|c| c.to_s}.include?(self.elementable_type)
  end

  def compute_position!

    # Don't do anything if it's not nil
    return unless self.position.nil?

    # If there's no container associated, don't do anything
    return if self.container_id.nil?

    self.position = Element.where(container: self.container).count
  end

  def correct_variable_name?

    if self.variable_name.nil? || (self.variable_name.match /\A[a-zA-Z0-9_-]{1,20}\z/).nil?
      errors.add :variable_name
    end
  end
end
