# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ProviderPackagesQueryParameters
    include ActiveModel::Validations

    attr_accessor :sortFilter, :selectedFilter,
                  :contentTypeFilter

    validates :sortFilter, inclusion: { in: %w[name relevance],
                                        message: 'Invalid Query Parameter for sort' }, allow_nil: true
    validates :selectedFilter, inclusion: { in: %w[true false ebsco all],
                                            message: 'Invalid Query Parameter for filter[selected]' }, allow_nil: true
    validates :contentTypeFilter, inclusion: { in: %w[aggregatedfulltext abstractandindex ebook ejournal print onlinereference unknown all],
                                               message: 'Invalid Query Parameter for filter[type]' }, allow_nil: true

    def initialize(params = {})
      filters = params.fetch(:filter, nil)
      @sortFilter = params[:sort]
      @selectedFilter = hash?(filters) ? filters[:selected] : filters
      @contentTypeFilter = hash?(filters) ? filters[:type] : filters
    end

    private

    def hash?(filters)
      if filters.respond_to?(:dig)
        true
      else
        false
      end
    end
  end
end
# rubocop:enable Naming/VariableName
