# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceParameters
    include ActiveModel::Validations

    attr_accessor :isSelected, :isHidden, :customCoverageList,
                  :embargoUnit, :embargoValue, :coverageStatement

    # Deselected resources cannot be customized.  Though the UI is smart enough
    # to keep this from happening, a manual request to the API could lead
    # to confusing behavior unless we signal a failure code here.
    # TODO: clearer messaging might be nice here
    with_options unless: :isSelected do
      validates :isHidden, absence: true, unless: :isSelected
      validates :customCoverageList, absence: true, unless: :isSelected
      validates :embargoUnit, absence: true, unless: :isSelected
      validates :embargoValue, absence: true, unless: :isSelected
      validates :coverageStatement, absence: true, unless: :isSelected
    end

    def initialize(params = {})
      @isSelected = params[:isSelected]
      @isHidden = params.dig(:visibilityData, :isHidden)
      @customCoverageList = params[:customCoverageList]
      @embargoUnit = params.dig(:customEmbargoPeriod, :embargoUnit)
      @embargoValue = params.dig(:customEmbargoPeriod, :embargoValue)
      @coverageStatement = params[:coverageStatement]
    end
  end
end

# rubocop:enable Naming/VariableName
