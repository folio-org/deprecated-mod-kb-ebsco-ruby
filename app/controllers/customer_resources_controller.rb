class CustomerResourcesController < ApplicationController
  attr_accessor :customer_resource

  before_action :set_customer_resource

  def show
    render jsonapi: @customer_resource,
           include: params[:include]
  end

  def update
    params = DeserializableCustomerResource.new(params).to_h
    @customer_resource.update customer_resource_params

    render status: :no_content
  end

  private

  def set_customer_resource
    @customer_resource = customer_resources.find customer_resource_id
  end

  def customer_resource_id
    [:vendor_id, :package_id, :title_id].zip(
      params[:id].split('-')
    ).to_h
  end

  def customer_resources
    CustomerResource.configure config
  end

  def customer_resource_params
    params
      .permit(
        :isSelected,
        visibilityData: [ :isHidden ],
        customCoverageList: [
          [ :beginCoverage, :endCoverage ]
        ],
        customEmbargoPeriod: [
          :embargoUnit,
          :embargoValue
        ]
      )
  end
end
