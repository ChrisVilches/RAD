class Query < ApplicationRecord
  has_many :query_histories
  belongs_to :view

  validate :config_is_correct?

  has_one :content, ->(query) { where(query_id: query.id).order("created_at DESC") }, class_name: QueryHistory.to_s

  # Validates the configuration. For example if a certain version of the configuration
  # is set to be something like:
  # {
  #   type: "numerical",
  #   min: 4,
  #   max: 10,
  #   label: "Age",
  #   placeholder: "This is a numerical input"
  # }
  # Then it outputs an error if the hash contains something like
  # {
  #   range: [4, 10]
  # }
  # because this format wasn't set.
  # This method checks self.config in its entirety (without mattering which
  # config version it is).
  # @return [Boolean]
  def config_is_correct?
    content = self.content
    puts "config here..."
    puts content
    puts content.class
    return true
  end

  # Validate parameters passed to the query to be formed
  # For example if the query is configured to have an numerical input
  # that has a range of 1 - 5 and the input contains a 6, then this
  # method returns the errors.
  # This method needs to be an instance method because the input parameters are
  # related to the config of self.
  # @param [Hash] parameters It contains the parameters to eval the query using the configuration hash.
  # TODO write return comment
  def input_parameters_valid?(parameters)

    return true
  end

  def build_sql(parameters)
    raise "Error" unless self.input_parameters_valid?(parameters)
  end

end
