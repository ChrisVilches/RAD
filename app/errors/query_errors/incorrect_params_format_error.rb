module QueryErrors
  class IncorrectParamsFormatError < StandardError
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def message
      "Incorrect format: #{params}"
    end
  end
end
