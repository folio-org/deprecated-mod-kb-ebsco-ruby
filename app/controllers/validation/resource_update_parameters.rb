# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceUpdateParameters
    include ActiveModel::Validations

    attr_accessor :isSelected, :isHidden, :customCoverageList, :contributorsList,
                  :identifiersList, :embargoUnit, :embargoValue, :coverageStatement

    # Deselected resources cannot be customized.  Though the UI is smart enough
    # to keep this from happening, a manual request to the API could lead
    # to confusing behavior unless we signal a failure code here.
    # TODO: clearer messaging might be nice here
    with_options unless: :isSelected do
      validates :isHidden, absence: true, unless: :isSelected
      validates :customCoverageList, absence: true, unless: :isSelected
      validates :contributorsList, absence: true, unless: :isSelected
      validates :identifiersList, absence: true, unless: :isSelected
      validates :embargoUnit, absence: true, unless: :isSelected
      validates :embargoValue, absence: true, unless: :isSelected
      validates :coverageStatement, absence: true, unless: :isSelected
    end

    validate :identifiers_list_valid?, unless: -> { identifiersList.blank? }

    def identifiers_list_valid? # rubocop:disable Metrics/AbcSize
      identifiersList.each do |identifier|
        errors.add(:IdentifierId, ':Invalid/Exceeded Length of Identifier id') unless
        identifier['id'] && identifier['id'].instance_of?(String) && identifier['id'].length <= 20
        errors.add(:IdentifierType, ':Invalid Identifier type') unless
          identifier['type']&.between?(0, 1)
        errors.add(:IdentifierSubType, ':Invalid Identifier subtype') unless
          identifier['subtype']&.between?(1, 2)
      end
    end

    def initialize(params = {})
      @isSelected = params[:isSelected]
      @isHidden = params.dig(:visibilityData, :isHidden)
      @customCoverageList = params[:customCoverageList]
      @contributorsList = params[:contributorsList]
      @identifiersList = params[:identifiersList]
      @embargoUnit = params.dig(:customEmbargoPeriod, :embargoUnit)
      @embargoValue = params.dig(:customEmbargoPeriod, :embargoValue)
      @coverageStatement = params[:coverageStatement]
    end
  end
end

# rubocop:enable Naming/VariableName
