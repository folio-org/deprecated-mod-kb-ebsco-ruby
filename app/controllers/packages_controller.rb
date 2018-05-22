# frozen_string_literal: true

class PackagesController < ApplicationController
  deserializable_resource :package, only: %i[create update],
                                    class: DeserializablePackage

  def index
    @result = packages.where! params
    render jsonapi: @result.data,
           meta: @result.meta,
           class: { Package: SerializablePackageList }
  end

  def show
    @result = packages.find! params[:id]
    render jsonapi: @result.data, include: params[:include]
  end

  def create
    @result = packages.create! package_create_params
    render jsonapi: @result.data
  end

  def update
    @result = packages.update! params[:id], package_update_params
    render jsonapi: @result.data
  end

  def destroy
    packages.destroy! params[:id]
  end

  # Relationships
  def resources
    @resources = find_resources(
      page: params[:page],
      q: params[:q],
      filter: params[:filter],
      sort: params[:sort]
    )
    render jsonapi: @resources.titles.to_a,
           meta: { totalResults: @resources.totalResults }
  end

  private

  def packages
    PackagesRepository.new(config: config)
  end

  def package
    packages.find!(params[:id]).data
  end

  def find_resources(**params)
    Resource.configure(config).find_by_package(
      vendor_id: package.provider_id,
      package_id: package.package_id,
      **params
    )
  end

  def package_params
    params
      .require(:package)
      .permit(
        :name,
        :contentType,
        :isSelected,
        :allowKbToAddTitles,
        visibilityData: [:isHidden],
        customCoverage: %i[beginCoverage endCoverage]
      )
  end

  def package_create_params
    package_params.slice(:name, :contentType, :customCoverage)
  end

  def package_update_params
    if package.is_custom
      package_params
    else
      package_params.except(:name, :contentType)
    end
  end
end
