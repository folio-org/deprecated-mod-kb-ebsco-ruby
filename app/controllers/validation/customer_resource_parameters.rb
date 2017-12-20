module Validation
  class CustomerResourceParameters
    include ActiveModel::Validations

    attr_accessor :isSelected, :isHidden, :customCoverageList, :embargoUnit, :embargoValue

    # Deselected resources cannot be customized.  Though the UI is smart enough
    # to keep this from happening, a manual request to the API could lead
    # to confusing behavior unless we signal a failure code here.
    # TODO: clearer messaging might be nice here
    with_options unless: :isSelected do |customer_resource|
      customer_resource.validates :isHidden, absence: true, unless: :isSelected
      customer_resource.validates :customCoverageList, absence: true, unless: :isSelected
      customer_resource.validates :embargoUnit, absence: true, unless: :isSelected
      customer_resource.validates :embargoValue, absence: true, unless: :isSelected
    end

    def initialize(params={})
      @isSelected = params[:isSelected]
      @isHidden = params.dig(:visibilityData, :isHidden)
      @customCoverageList = params[:customCoverageList]
      @embargoUnit = params.dig(:customEmbargoPeriod, :embargoUnit)
      @embargoValue = params.dig(:customEmbargoPeriod, :embargoValue)
    end
  end
end
