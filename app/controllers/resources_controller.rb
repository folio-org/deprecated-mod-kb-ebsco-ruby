# frozen_string_literal: true

class ResourcesController < ApplicationController
  attr_accessor :resource

  before_action :set_resource, only: %i[show update destroy]

  deserializable_resource :resource,
                          only: %i[create update],
                          class: DeserializableResource

  # rubocop:disable Metrics/AbcSize
  def create
    # A resource represents the relationship between a package
    # and title.  So in this `create` method we're really just
    # associating a title (managed or custom) with a package (custom only)
    # via the `isSelected` property.

    provider_id, package_id = resource_create_params[:packageId].split('-')
    title_id = resource_create_params[:titleId]
    url = resource_create_params[:url]

    package = PackagesRepository.new(config: config)
                                .find!(resource_create_params[:packageId])
                                .data
    title = Title.configure(config).find(title_id)

    resource_validation =
      Validation::ResourceAssociateParameters.new(
        packageId: resource_create_params[:packageId],
        titleId: title_id,
        package: package,
        title: title,
        url: url
      )

    if resource_validation.valid?
      @resource = resources.create_resource(
        vendor_id: provider_id.to_i,
        package_id: package_id.to_i,
        title_id: title_id.to_i,
        isSelected: true,
        titleName: title.titleName,
        pubType: title.pubType,
        url: url
      )
      render jsonapi: @resource
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

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
    resource_id_validation =
      Validation::ResourceID.new(resource_id)

    if resource_id_validation.valid?
      @resource = resources.find resource_id
    else
      render jsonapi_errors: resource_id_validation.errors,
             status: :bad_request
    end
  end

  def resource_id
    vendor_id, package_id, title_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id, title_id: title_id }
  end

  def resources
    Resource.configure config
  end

  def resource_create_params
    params
      .require(:resource)
      .permit(
        :titleId,
        :packageId,
        :url
      )
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
        :titleId,
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
        proxy: [:id],
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
