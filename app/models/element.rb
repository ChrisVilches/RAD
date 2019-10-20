class Element < ApplicationRecord
  belongs_to :elementable, :polymorphic => true
  belongs_to :container
  validates :elementable, presence: true
end
