# frozen_string_literal: true

class ResourcesController < ApplicationController
  attr_accessor :resource

  before_action :set_resource, only: %i[show update destroy]

  deserializable_resource :resource,
                          only: %i[create update],
                          class: DeserializableResource
  def create
    resource_validation =
      Validation::ResourceCreateParameters.new(resource_params)

    if resource_validation.valid?
      @resource = resources.create_resource(resource_params)
      render jsonapi: @resource
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  end

  def show
    render jsonapi: @resource,
           include: params[:include]
  end

  def update
    resource_validation =
      Validation::ResourceUpdateParameters.new(update_params)

    if resource_validation.valid?
      @resource.update update_params
      render jsonapi: @resource
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  end

  def destroy
    resource_validation =
      Validation::ResourceDestroyParameters.new(@resource.customerResourcesList)

    if resource_validation.valid?
      @resource.delete
    else
      render jsonapi_errors: resource_validation.errors,
             status: :bad_request
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
        :isPeerReviewed,
        :publisherName,
        :edition,
        :description,
        :url,
        :packageId,
        visibilityData: %i[isHidden reason],
        customCoverageList: [
          %i[beginCoverage endCoverage]
        ],
        contributorsList: [
          %i[type contributor]
        ],
        identifiersList: [
          %i[id subtype type]
        ],
        customEmbargoPeriod: %i[
          embargoUnit
          embargoValue
        ]
      )
  end

  def update_params
    # NOTE: deserialization happens before param parsing, so we
    # use the RMAPI property names here
    params
      .require(:resource)
      .permit(
        :titleName,
        :pubType,
        :isSelected,
        :coverageStatement,
        :isPeerReviewed,
        :publisherName,
        :edition,
        :description,
        :url,
        visibilityData: %i[isHidden reason],
        customCoverageList: [
          %i[beginCoverage endCoverage]
        ],
        contributorsList: [
          %i[type contributor]
        ],
        identifiersList: [
          %i[id subtype type]
        ],
        customEmbargoPeriod: %i[
          embargoUnit
          embargoValue
        ]
      )
  end
end
