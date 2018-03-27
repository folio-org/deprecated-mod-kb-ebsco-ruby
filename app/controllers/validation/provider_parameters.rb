# frozen_string_literal: true

module Validation
  class ProviderParameters
    include ActiveModel::Validations

    attr_accessor :value

    validates :value, presence: true

    def initialize(params = {})
      @value = params.dig(:providerToken, :value)
    end
  end
end
