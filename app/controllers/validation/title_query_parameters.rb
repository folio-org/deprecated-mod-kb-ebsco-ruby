# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class TitleQueryParameters
    include ActiveModel::Validations

    attr_accessor :searchField, :selectedFilter,
                  :contentTypeFilter

    validates :searchField, inclusion: { in: %w[title isxn publisher subject],
                                         message: 'Invalid Query Parameter for searchfield' }, allow_nil: true
    validates :selectedFilter, inclusion: { in: %w[true false ebsco],
                                            message: 'Invalid Query Parameter for filter[:selected]' }, allow_nil: true
    validates :contentTypeFilter, inclusion: { in: %w[audiobook book bookseries database journal newsletter newspaper proceedings report streamingaudio streamingvideo thesisdissertation website unspecified],
                                               message: 'Invalid Query Parameter for filter[:type]' }, allow_nil: true

    def initialize(params = {})
      filters = params.fetch(:filter, nil)
      @searchField = params[:searchfield]
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
