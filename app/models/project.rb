class Project < ApplicationRecord
  has_many :views
  belongs_to :company
end
