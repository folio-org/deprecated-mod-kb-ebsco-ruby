# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceCreateParameters
    include ActiveModel::Validations

    attr_accessor :titleName, :pubType, :packageId, :publisherName,
                  :isPeerReviewed, :edition, :description, :url,
                  :customCoverageList, :contributorsList, :identifiersList,
                  :embargoUnit, :embargoValue, :coverageStatement

    validates :titleName, presence: true, length: { maximum: 400 }
    validates :pubType, presence: true
    validates :packageId, presence: true
    validates :publisherName, length: { maximum: 250 }, allow_nil: true
    validates :isPeerReviewed, inclusion: { in: [true, false], message: 'Invalid value' }, allow_nil: true
    validates :edition, length: { maximum: 250 }, allow_nil: true
    validates :description, length: { maximum: 1500 }, allow_nil: true
    validates :url, length: { maximum: 600 }, allow_nil: true
    validate :url_has_valid_format?, unless: -> { url.nil? }
    validates :coverageStatement, length: { maximum: 250 }, allow_nil: true
    validate :identifiers_list_valid?, unless: -> { identifiersList.blank? }

    def url_has_valid_format?
      errors.add(:url, ':url has invalid format') unless
        url.downcase.start_with?('https://', 'http://')
    end

    def identifiers_list_valid? # rubocop:disable Metrics/AbcSize
      identifiersList.each do |identifier|
        errors.add(:IdentifierId, ':Invalid Identifier id') unless
          identifier['id'] && identifier['id'].instance_of?(String) && identifier['id'].length <= 20
        errors.add(:IdentifierType, ':Invalid Identifier type') unless
          identifier['type']&.between?(0, 1)
        errors.add(:IdentifierSubType, ':Invalid Identifier subtype') unless
          identifier['subtype']&.between?(1, 2)
      end
    end

    def initialize(params = {}) # rubocop:disable Metrics/AbcSize
      @titleName = params[:titleName]
      @pubType = params[:pubType]
      @packageId = params[:packageId]
      @publisherName = params[:publisherName]
      @isPeerReviewed = params[:isPeerReviewed]
      @edition = params[:edition]
      @description = params[:description]
      @url = params[:url]
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
