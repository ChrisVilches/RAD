class View < ApplicationRecord
  has_many :queries
  belongs_to :project
  has_one :main_form_container, class_name: "Container"
end
