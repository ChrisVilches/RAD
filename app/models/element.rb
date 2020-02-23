class Element < ApplicationRecord

  strip_attributes only: [:label, :variable_name]
  belongs_to :elementable, :polymorphic => true, dependent: :destroy
  belongs_to :container
  validates :elementable, presence: true
  validate :allowed_elementable_value?
  validate :correct_variable_name?
  validate :label_requirement_satisfied? # Only containers don't need

  before_validation :allow_nil_label_for_containers!
  before_validation :compute_position!
  before_validation :set_correct_elementable_type!

  VARIABLE_NAME_REGEX = /\A[a-zA-Z0-9_-]{1,20}\z/

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

  # Elements table cannot have null label due to database constraints, but the
  # container element can have a blank label so this method makes a null label
  # become an empty string so that it can be saved to DB.
  def allow_nil_label_for_containers!
    if self.label.nil?
      self.label = ""
    end
  end

  def correct_variable_name?

    if self.variable_name.nil? || self.variable_name.length == 0 || (self.variable_name.match VARIABLE_NAME_REGEX).nil?
      errors.add :variable_name
    end
  end

  def label_requirement_satisfied?
    type = self.elementable_type
    return if type == Container.to_s
    label = self.label
    if label.nil? || label.length == 0
      errors.add :label
    end
  end
end
