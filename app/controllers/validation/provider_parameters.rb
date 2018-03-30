# frozen_string_literal: true

module Validation
  class ProviderParameters
    include ActiveModel::Validations

    attr_accessor :value

    def initialize(params = {})
      @value = params.dig(:vendorToken, :value)
    end
  end
end
