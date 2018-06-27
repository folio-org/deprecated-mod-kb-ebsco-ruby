# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ProviderQueryParameters
    include ActiveModel::Validations

    attr_accessor :sortFilter

    validates :sortFilter, inclusion: { in: %w[name relevance],
                                        message: 'Invalid Query Parameter for sort' }, allow_nil: true

    def initialize(params = {})
      @sortFilter = params[:sort]
    end
  end
end
# rubocop:enable Naming/VariableName
