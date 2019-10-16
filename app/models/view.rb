class View < ApplicationRecord
  has_many :queries
  belongs_to :project
end
