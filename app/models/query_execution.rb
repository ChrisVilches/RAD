class QueryExecution < ApplicationRecord
  include Tabulatable
  include DelegateSearchable
  belongs_to :query
  belongs_to :user
  belongs_to :connection
  belongs_to :query_history
  delegate :company, to: :query

  # TODO: Validate that query_history belongs to query. This can be done by normalizing the database and removing query.
  # (then, query is guessed using query_history)

  before_validation :nil_params_to_empty_array
  validate :validate_both_params
  validate :query_history_belongs_to_query

  enum status: {
    idle: 0,
    progress: 1,
    finished: 2,
    cancelled: 3
  }

  enum error: {
    unknown_error: 100,
    wrong_query_code: 200,
    wrong_query_param_replace: 201
    # TODO: Add more
  }

  class << self
    def params_valid?(params)
      instance = new
      key = :global # Can be global or query
      instance.validate_params_format(key, params)
      instance.errors[key].empty?
    end
  end

  def validate_params_format(key, params)
    raise ArgumentError if %i[global query].exclude?(key)
    return errors.add(key, 'must be array.') unless params.is_a?(Array)
    params.each do |param|
      param = param.dup.try(:symbolize_keys!)
      has_path = param.try(:key?, :path)
      has_value = param.try(:key?, :value)
      return errors.add(key, 'must be an array where every element has format { path: [String], value: any }') unless has_path && has_value
      path = param[:path]
      return errors.add(key, 'must have path as an array') unless path.is_a?(Array)
      return errors.add(key, 'must have non-empty path array') if path.empty?
      unless path.select { |x| !(x.is_a?(String) && x.match(Element::VARIABLE_NAME_REGEX)) }.empty?
        return errors.add(key, 'must have path as array of strings (with correct variable name pattern)')
      end
    end
  end

  private

  def nil_params_to_empty_array
    self.global_params ||= []
    self.query_params ||= []
  end

  def query_history_belongs_to_query
    errors.add(:query_history, 'must belong to query') if query_history.query != query
  end

  def validate_both_params
    validate_params_format(:global, global_params)
    validate_params_format(:query, query_params)
  end
end
