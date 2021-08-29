module QueryErrors
  class HasParamsNotReplacedError < StandardError
    attr_reader :param_names

    def initialize(param_names)
      @param_names = param_names
    end

    def message
      "The following parameters couldn't be replaced in your query: #{param_names.join(', ')}."
    end
  end
end
