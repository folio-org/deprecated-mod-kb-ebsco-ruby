# frozen_string_literal: true

class CustomerResourcesController < ApplicationController
  attr_accessor :customer_resource

  before_action :set_customer_resource, only: %i[show update]

  deserializable_resource :customer_resource,
                          only: :update,
                          class: DeserializableCustomerResource

  def show
    render jsonapi: @customer_resource,
           include: params[:include]
  end

  def update
    customer_resource_validation =
      Validation::CustomerResourceParameters.new(customer_resource_params)

    if customer_resource_validation.valid?
      @customer_resource.update customer_resource_params
      render jsonapi: @customer_resource
    else
      render jsonapi_errors: customer_resource_validation.errors,
             status: :unprocessable_entity
    end
  end

  private

  def set_customer_resource
    @customer_resource = customer_resources.find customer_resource_id
  end

  def customer_resource_id
    vendor_id, package_id, title_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id, title_id: title_id }
  end

  def customer_resources
    CustomerResource.configure config
  end

  def customer_resource_params
    # NOTE: deserialization happens before param parsing, so we
    # use the RMAPI property names here
    params
      .require(:customer_resource)
      .permit(
        :isSelected,
        :coverageStatement,
        visibilityData: [:isHidden],
        customCoverageList: [
          %i[beginCoverage endCoverage]
        ],
        customEmbargoPeriod: %i[
          embargoUnit
          embargoValue
        ]
      )
  end
end
