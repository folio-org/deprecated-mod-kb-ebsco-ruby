# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceUpdateParameters
    include ActiveModel::Validations

    attr_accessor :isSelected, :isHidden, :customCoverageList, :contributorsList,
                  :identifiersList, :embargoUnit, :embargoValue, :coverageStatement,
                  :edition, :url

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

    validates :edition, length: { maximum: 250 }, allow_nil: true
    validate :identifiers_list_valid?, unless: -> { identifiersList.blank? }
    validate :url_has_valid_format?, unless: -> { url.blank? }
    validate :custom_coverage_list_valid?, unless: -> { customCoverageList.blank? }

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
      @isSelected = params[:isSelected]
      @isHidden = params.dig(:visibilityData, :isHidden)
      @customCoverageList = params[:customCoverageList]
      @contributorsList = params[:contributorsList]
      @identifiersList = params[:identifiersList]
      @embargoUnit = params.dig(:customEmbargoPeriod, :embargoUnit)
      @embargoValue = params.dig(:customEmbargoPeriod, :embargoValue)
      @coverageStatement = params[:coverageStatement]
      @edition = params[:edition]
      @url = params[:url]
    end
  end
end

# rubocop:enable Naming/VariableName
