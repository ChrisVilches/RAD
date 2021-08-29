class Query < ApplicationRecord
  include DelegateSearchable
  has_many :query_histories, dependent: :destroy
  belongs_to :view
  delegate :company, to: :view
  delegate :project, to: :view
  has_one :container, as: :inputable
  has_and_belongs_to_many :connections

  # TODO: Lambda has the same code. Recycle code.
  has_one :latest_revision, ->(query) {where(query_id: query.id).order(created_at: :desc) }, class_name: QueryHistory.to_s
  has_many :log, ->(query) {where(query_id: query.id).order(created_at: :desc) }, class_name: QueryHistory.to_s
  validates :name, presence: true, allow_blank: false

  def connections_allowed_to(user)
    user_id = nil
    if user.is_a?(User)
      user_id = user.id
    elsif user.is_a?(Numeric)
      user_id = user
    end

    raise 'User is null. Should be User or Numeric.' if user_id.nil?

    connections
      .joins(:connections_users)
      .where('connections_users.user_id': user_id)
  end
end
