module ContainerErrors
  class IncorrectContainerError
    attr_reader :container_errors
    def initialize(errors)
      @container_errors = errors
    end
  end
end
