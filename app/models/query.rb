class Query < ApplicationRecord
  has_many :query_histories
  belongs_to :view
  has_one :container, as: :inputable

  validate :config_is_correct?

  has_one :latest_revision, ->(query) { where(query_id: query.id).order("created_at DESC") }, class_name: QueryHistory.to_s

  class IncorrectParams < StandardError
    attr_reader :global_form_errors, :query_form_errors

    def initialize(global_form_errors: nil, query_form_errors: nil)
      @global_form_errors = global_form_errors
      @query_form_errors = query_form_errors
    end

    def message
      "Error building SQL, input parameters are invalid."
    end
  end

  class HasParamsNotReplaced < StandardError

    attr_reader :param_names

    def initialize(param_names)
      @param_names = param_names
    end

    def message
      "The following parameters couldn't be replaced in your query: #{param_names.join(", ")}."
    end
  end

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
    content = self.latest_revision
    #puts "config here..."
    #puts content
    #puts content.class
    return true
  end

  # Validate parameters passed to the query to be formed
  # For example if the query is configured to have an numerical input
  # that has a range of 1 - 5 and the input contains a 6, then this
  # method returns the errors.
  # This method needs to be an instance method because the input parameters are
  # related to the config of self.
  # @param [Hash] global_params
  # @param [Hash] query_params
  # TODO write return comment
  def input_parameters_errors(query_params = [], global_params = [])

    global_container = self.view.container
    query_container = self.container

    global_form_errors = global_container.user_inputs_errors(global_params)
    query_form_errors = query_container.user_inputs_errors(query_params)

    if (global_form_errors + query_form_errors).empty?
      return nil # No errors
    end

    return {
      global_form_errors: global_form_errors,
      query_form_errors: query_form_errors
    }
  end

  def build_sql(query_params = [], global_params = [])

    input_errors = self.input_parameters_errors(query_params, global_params)

    unless input_errors.nil?
      raise IncorrectParams.new(input_errors)
    end

    latest_revision = self.latest_revision

    sql = latest_revision.content["sql"]

    # TODO This way of replacing parameters is really cheap.
    # Improve it.
    query_params.each do |p|
      param_name = p[:path].join(".")
      sql = sql.gsub("{{#{param_name}}}", p[:value].to_s)
    end

    # TODO Here's a place that can be greatly improved in the future.
    # Instead of simply having the option of using a SQL, also give the
    # option of having a code (JS, Ruby, etc) that also uses
    # the [dummy_element-1][dummy_element-2][etc] variables and then
    # returns a SQL code. This way the user can vary the logic for SQL
    # generation.

    # But let's keep it simple for now... each query simply has SQL code as
    # input and a relation as result. Not things like for example...
    # do SQL, use JS (as explained above) and analyze the result and then do
    # another SQL if the result matches some condition.
    # Just one SQL and one relation result is enough.

    remaining_params = sql.scan(/{{[a-zA-Z0-9_-]{1,20}}}/)
    unless remaining_params.empty?
      raise HasParamsNotReplaced.new(remaining_params)
    end

    return sql
  end

end
