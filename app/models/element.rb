class Element < ApplicationRecord
  strip_attributes only: %i[label variable_name]
  belongs_to :elementable, polymorphic: true, dependent: :destroy
  belongs_to :container
  validates :elementable, presence: true
  validate :allowed_elementable_value?
  validate :correct_variable_name?
  validate :label_requirement_satisfied? # Only containers don't need
  validate :elementable_also_valid?

  before_validation :allow_nil_label_for_containers!
  before_validation :compute_position!
  before_validation :set_correct_elementable_type!

  VARIABLE_NAME_REGEX = /\A[a-zA-Z0-9_-]{1,20}\z/.freeze

  private

  # TODO: This should be automatic, but I cannot get the ORM to do it automatically.
  # The elementable_type column should be set with the specific class name, and
  # not Input.
  def set_correct_elementable_type!
    self.elementable_type = elementable.class.to_s
  end

  def allowed_elementable_value?
    allowed = [TextInput, NumericInput, OptionInput, Container]
    return if allowed.map(&:to_s).include?(elementable_type)
    errors.add :elementable_type
  end

  def compute_position!
    # Don't do anything if it's not nil
    return unless position.nil?

    # If there's no container associated, don't do anything
    return if container_id.nil?

    self.position = Element.where(container: container).count
  end

  # Elements table cannot have null label due to database constraints, but the
  # container element can have a blank label so this method makes a null label
  # become an empty string so that it can be saved to DB.
  def allow_nil_label_for_containers!
    self.label = '' if label.nil?
  end

  def correct_variable_name?
    return unless variable_name.nil? || variable_name.length.zero? || (variable_name.match VARIABLE_NAME_REGEX).nil?
    errors.add :variable_name
  end

  def label_requirement_satisfied?
    type = elementable_type
    return if type == Container.to_s
    label = self.label
    errors.add :label if label.nil? || label.length.zero?
  end

  def elementable_also_valid?
    errors.add :elementable if elementable.nil? || !elementable.valid?
  end
end
