# frozen_string_literal: true

class ResourcesController < ApplicationController
  attr_accessor :resource

  before_action :set_resource, only: %i[show update]

  deserializable_resource :resource,
                          only: :update,
                          class: DeserializableResource

  def show
    render jsonapi: @resource,
           include: params[:include]
  end

  def update
    resource_validation =
      Validation::ResourceParameters.new(resource_params)

    if resource_validation.valid?
      @resource.update resource_params
      render jsonapi: @resource
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  end

  private

  def set_resource
    @resource = resources.find resource_id
  end

  def resource_id
    vendor_id, package_id, title_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id, title_id: title_id }
  end

  def resources
    Resource.configure config
  end

  def resource_params
    # NOTE: deserialization happens before param parsing, so we
    # use the RMAPI property names here
    params
      .require(:resource)
      .permit(
        :titleName,
        :pubType,
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
