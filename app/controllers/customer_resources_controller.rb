class CustomerResourcesController < ApplicationController
  attr_accessor :customer_resource

  before_action :set_customer_resource, only: [:show, :update]

  deserializable_resource :customer_resource, only: :update

  def show
    render jsonapi: @customer_resource,
           include: params[:include]
  end

  def update
    @customer_resource.update customer_resource_params
    render jsonapi: @customer_resource
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
      .require(:customer_resource)
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
