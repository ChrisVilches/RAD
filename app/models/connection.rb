class Connection < ApplicationRecord
  include Tabulatable
  include DelegateSearchable
  self.filter_attributes += [:pass]
  strip_attributes except: :pass
  belongs_to :project
  has_and_belongs_to_many :users
  has_and_belongs_to_many :queries
  enum color: { white: 0, black: 1, red: 2, yellow: 3, blue: 4, green: 5, pink: 6, purple: 7, orange: 8, gray: 9 }

  validates :name, presence: true
  validates :host, presence: true

  enum db_type: {
    mysql: 0,
    postgres: 1
  }

  def increase_used_times!
    # TODO: Timezone might be set incorrectly.
    update(last_executed_at: DateTime.now, used_times: used_times + 1)
  end
end
