require 'active_support/concern'

module FormComponent
  extend ActiveSupport::Concern

  module ClassMethods
    def configurable_params
      raise NotImplementedError
    end
  end
end
