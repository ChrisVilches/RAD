class View < ApplicationRecord
  has_many :queries
  belongs_to :project
  has_one :container, as: :inputable
  delegate :company, to: :project
end
