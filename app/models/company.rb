class Company < ApplicationRecord
  has_many :participations
  has_many :users, through: :participations

  has_many :projects
  validates_length_of :url, minimum: 2, maximum: 50, allow_blank: false

  before_validation :lower_url

  private

  def lower_url
    self.url = url.strip.downcase
  end
end
