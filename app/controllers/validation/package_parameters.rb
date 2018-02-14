# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class PackageParameters
    include ActiveModel::Validations

    attr_accessor :isSelected, :isHidden, :allowEbscoToAddTitles,
                  :beginCoverage, :endCoverage

    # Deselected packages cannot be customized.  Though the UI is smart enough
    # to keep this from happening, a manual request to the API could lead
    # to confusing behavior unless we signal a failure code here.
    # TODO: clearer messaging might be nice here
    with_options unless: :isSelected do
      validates :allowEbscoToAddTitles, absence: true, unless: :isSelected
      validates :isHidden, absence: true, unless: :isSelected
      validates :beginCoverage, absence: true, unless: :isSelected
      validates :endCoverage, absence: true, unless: :isSelected
    end

    def initialize(params = {})
      @isSelected = params[:isSelected]
      @allowEbscoToAddTitles = params[:allowEbscoToAddTitles]
      @isHidden = params.dig(:visibilityData, :isHidden)
      @beginCoverage = params.dig(:customCoverage, :beginCoverage)
      @endCoverage = params.dig(:customCoverage, :endCoverage)
    end
  end
end

# rubocop:enable Naming/VariableName
