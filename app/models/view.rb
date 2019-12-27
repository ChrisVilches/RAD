class View < ApplicationRecord
  has_many :queries
  belongs_to :project
  has_one :container, as: :inputable
end
