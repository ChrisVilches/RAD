class Project < ApplicationRecord
  has_many :views
  belongs_to :company

  has_many :project_participations
  has_many :users, through: :project_participations
end
