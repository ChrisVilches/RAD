module QueryServices
  class SqlBuilderService
    class << self
      def build_sql(query_history, query_params, global_params)
        raise QueryErrors::IncorrectParamsFormatError, query_params unless QueryExecution.params_valid?(query_params)
        raise QueryErrors::IncorrectParamsFormatError, global_params unless QueryExecution.params_valid?(global_params)

        query_params.map!(&:symbolize_keys)
        global_params.map!(&:symbolize_keys)

        input_errors = input_parameters_errors(query_history.query, query_params, global_params)

        raise QueryErrors::IncorrectParamsError, input_errors unless input_errors.nil?

        sql = sql_code(query_history)
        sql = replace_params(sql, query_params, global_params)
        raise QueryErrors::NoSqlPresentError unless sql.present?

        validate_all_params_replaced!(sql)
        sql
      end

      private

      # TODO: This way of replacing parameters is really cheap. Improve it.
      # TODO: Needs to replace also global parameters.
      def replace_params(sql, query_params, global_params)
        return nil unless sql.present?
        query_params.each do |p|
          param_name = p[:path].join('.')
          del_left = '{{'
          del_right = '}}'
          sql = sql.gsub(Regexp.new("#{del_left}\\s*#{param_name}\\s*#{del_right}"), p[:value].to_s)
        end
        sql
      end

      def sql_code(query_history)
        query_history&.content.try(:[], 'sql')
      end

      def validate_all_params_replaced!(sql)
        remaining_params = sql.scan(/{{[a-zA-Z0-9_-]{1,20}}}/)
        raise QueryErrors::HasParamsNotReplaced, remaining_params unless remaining_params.empty?
      end

      # Validate parameters passed to the query to be formed
      # For example if the query is configured to have an numerical input
      # that has a range of 1 - 5 and the input contains a 6, then this
      # method returns the errors.
      # This method needs to be an instance method because the input parameters are
      # related to the config of self.
      # @param [Hash] global_params
      # @param [Hash] query_params
      # TODO: write return comment
      def input_parameters_errors(query, query_params, global_params)
        global_container = query.view.container
        query_container = query.container

        global_form_errors = []
        query_form_errors = []

        begin
          global_form_errors = global_container.user_inputs_errors(global_params)
          query_form_errors = query_container.user_inputs_errors(query_params)
        rescue
          # TODO: Some errors occurred while executing 'user_inputs_errors',
          # so these have to be somehow added to the error list.
        end

        if (global_form_errors + query_form_errors).empty?
          return nil # No errors
        end

        {
          global_form_errors: global_form_errors,
          query_form_errors: query_form_errors
        }
      end
    end
  end
end
