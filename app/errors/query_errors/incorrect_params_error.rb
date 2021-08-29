module QueryErrors
  class IncorrectParamsError < StandardError
    attr_reader :global_form_errors, :query_form_errors

    def initialize(global_form_errors: nil, query_form_errors: nil)
      @global_form_errors = global_form_errors
      @query_form_errors = query_form_errors
    end

    def message
      'Error building SQL, input parameters are invalid.'
    end
  end
end
