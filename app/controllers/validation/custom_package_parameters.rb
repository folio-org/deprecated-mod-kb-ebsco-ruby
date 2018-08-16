# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class CustomPackageParameters
    include ActiveModel::Validations

    attr_accessor :name, :contentType, :beginCoverage, :endCoverage

    validates :name, presence: true
    validates :contentType, presence: true
    validate :begin_coverage_valid_date_format?, unless: -> { beginCoverage.blank? }
    validate :end_coverage_valid_date_format?, unless: -> { endCoverage.blank? }

    def begin_coverage_valid_date_format?
      errors.add(:beginCoverage, 'has invalid format. Should be YYYY-MM-DD') unless
        valid_date?(beginCoverage)
    end

    def end_coverage_valid_date_format?
      errors.add(:endCoverage, 'has invalid format. Should be YYYY-MM-DD') unless
        valid_date?(endCoverage)
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

    # TODO: this should turn snake as soon as it
    # comes out of the deserializable layer.  also
    # we should probably validate more than presence on these.
    # content_type is an enum, and name could be arbitrarily
    # long to the point that RMAPI throws the error instead of us

    def initialize(params = {})
      @name = params[:name]
      @contentType = params[:contentType]
      @beginCoverage = params.dig(:customCoverage, :beginCoverage)
      @endCoverage = params.dig(:customCoverage, :endCoverage)
    end
  end
end

# rubocop:enable Naming/VariableName
