# frozen_string_literal: true

module Validation
  class ProviderParameters
    include ActiveModel::Validations

    attr_accessor :value

    validates :value, length: { maximum: 500 }

    def initialize(params = {})
      @value = params.dig(:vendorToken, :value)
    end
  end
end
