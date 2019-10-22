class Element < ApplicationRecord
  belongs_to :elementable, :polymorphic => true
  belongs_to :container
  validates :elementable, presence: true

  before_validation :compute_position

  private
  def compute_position

    # Don't do anything if it's not nil
    return unless self.position.nil?

    # If there's no container associated, don't do anything
    return if self.container_id.nil?

    self.position = Element.where(container: self.container).count
  end
end
