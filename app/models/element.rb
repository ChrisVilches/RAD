class Element < ApplicationRecord
  belongs_to :elementable, :polymorphic => true
  belongs_to :container
end
