# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceUpdateParameters
    include ActiveModel::Validations

    attr_accessor :isTitleCustom, :isSelected, :isHidden, :customCoverageList, :contributorsList,
                  :identifiersList, :embargoUnit, :embargoValue, :coverageStatement,
                  :edition, :titleName, :isPeerReviewed, :pubType, :publisherName, :description, :url

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

    with_options unless: :isTitleCustom do
      validates :titleName, absence: true, unless: :isTitleCustom
      validates :isPeerReviewed, absence: true, unless: :isTitleCustom
      validates :pubType, absence: true, unless: :isTitleCustom
      validates :publisherName, absence: true, unless: :isTitleCustom
      validates :edition, absence: true, unless: :isTitleCustom
      validates :description, absence: true, unless: :isTitleCustom
      validates :url, absence: true, unless: :isTitleCustom
      validates :contributorsList, absence: true, unless: :isTitleCustom
      validates :identifiersList, absence: true, unless: :isTitleCustom
    end

    validates :edition, length: { maximum: 250 }, allow_nil: true
    validate :identifiers_list_valid?, unless: -> { identifiersList.blank? }
    validate :url_has_valid_format?, unless: -> { url.nil? }

    def identifiers_list_valid?
      identifiersList.each do |identifier|
        errors.add(:IdentifierId, ':Invalid/Exceeded Length of Identifier id') unless
        identifier['id']&.instance_of?(String) && identifier['id'].length <= 20
        errors.add(:IdentifierType, ':Invalid Identifier type') unless
          identifier['type']&.between?(0, 9)
        errors.add(:IdentifierSubType, ':Invalid Identifier subtype') unless
          identifier['subtype']&.between?(0, 7)
      end
    end

    def url_has_valid_format?
      errors.add(:url, 'has invalid format') unless
        url.downcase.start_with?('https://', 'http://')
    end

    def initialize(is_title_custom, params = {})
      @isTitleCustom = is_title_custom
      @isSelected = params[:isSelected]
      @isHidden = params.dig(:visibilityData, :isHidden)
      @customCoverageList = params[:customCoverageList]
      @contributorsList = params[:contributorsList]
      @identifiersList = params[:identifiersList]
      @embargoUnit = params.dig(:customEmbargoPeriod, :embargoUnit)
      @embargoValue = params.dig(:customEmbargoPeriod, :embargoValue)
      @coverageStatement = params[:coverageStatement]
      @edition = params[:edition]
      @titleName = params[:titleName]
      @isPeerReviewed = params[:isPeerReviewed]
      @pubType = params[:pubType]
      @publisherName = params[:publisherName]
      @description = params[:description]
      @url = params[:url]
    end
  end
end

# rubocop:enable Naming/VariableName
