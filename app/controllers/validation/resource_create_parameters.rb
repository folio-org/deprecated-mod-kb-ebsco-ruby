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
    validate :custom_coverage_list_valid?, unless: -> { customCoverageList.blank? }

    def url_has_valid_format?
      errors.add(:url, ':url has invalid format') unless
        url.downcase.start_with?('https://', 'http://')
    end

    def identifiers_list_valid?
      identifiersList.each do |identifier|
        errors.add(:IdentifierId, ':Invalid Identifier id') unless
          identifier['id']&.instance_of?(String) && identifier['id'].length <= 20
        errors.add(:IdentifierType, ':Invalid Identifier type') unless
          identifier['type']&.between?(0, 7)
        errors.add(:IdentifierSubType, ':Invalid Identifier subtype') unless
          identifier['subtype']&.between?(1, 2)
      end
    end

    def custom_coverage_list_valid?
      customCoverageList.each do |custom_coverage|
        begin_coverage = custom_coverage['beginCoverage']
        end_coverage = custom_coverage['endCoverage']
        begin_coverage_valid_date_format?(begin_coverage) unless begin_coverage.nil?
        end_coverage_valid_date_format?(end_coverage) unless end_coverage.nil?
      end
    end

    def begin_coverage_valid_date_format?(begin_coverage)
      errors.add(:beginCoverage, 'has invalid format. Should be YYYY-MM-DD') unless
        valid_date?(begin_coverage)
    end

    def end_coverage_valid_date_format?(end_coverage)
      errors.add(:endCoverage, 'has invalid format. Should be YYYY-MM-DD') unless
        valid_date?(end_coverage)
    end

    def valid_date?(coverage)
      yyyy, mm, dd = coverage.split('-')
      begin
        @valid_date = Date.new(yyyy.to_i, mm.to_i, dd.to_i)
        return true
      rescue ArgumentError
        return false
      end
    end

    def initialize(params = {})
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
