class Query < ApplicationRecord
  has_many :query_histories
  belongs_to :view

  validate :config_is_correct?

  def config_is_correct?
    config = self.config
    puts "config here..."
    puts config
    puts config.class
    return true
  end
end
