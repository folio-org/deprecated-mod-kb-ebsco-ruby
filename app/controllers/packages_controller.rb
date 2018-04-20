# frozen_string_literal: true

class PackagesController < ApplicationController
  before_action :set_package, only: %i[show update destroy resources]

  deserializable_resource :package, only: %i[create update],
                                    class: DeserializablePackage

  def index
    @packages = packages.all(
      q: params[:q],
      page: params[:page],
      filter: params[:filter],
      sort: params[:sort]
    )

    render jsonapi: @packages.packagesList.to_a,
           meta: { totalResults: @packages.totalResults }
  end

  def create
    # Pass only those parameters that are allowed to be modified for
    # custom packages
    package_create_params = package_params.slice(
      :packageName,
      :contentType,
      :customCoverage
    )
    package_validation = Validation::CustomPackageParameters.new(package_create_params)

    if package_validation.valid?
      @package = packages.create_package(package_create_params)
      render jsonapi: @package
    else
      render jsonapi_errors: package_validation.errors,
             status: :unprocessable_entity
    end
  end

  def show
    render jsonapi: @package, include: params[:include]
  end

  def update
    package_validation = Validation::PackageParameters.new(package_params)

    if package_validation.valid?
      @package.update package_params
      render jsonapi: @package
    else
      render jsonapi_errors: package_validation.errors,
             status: :unprocessable_entity
    end
  end

  def destroy
    package_validation = Validation::PackageDestroyParameters.new(@package)

    if package_validation.valid?
      @package.delete
    else
      render jsonapi_errors: package_validation.errors,
             status: :bad_request
    end
  end

  # Relationships
  def resources
    @resources = @package.find_resources(
      page: params[:page],
      q: params[:q],
      filter: params[:filter],
      sort: params[:sort]
    )
    render jsonapi: @resources.titles.to_a,
           meta: { totalResults: @resources.totalResults }
  end

  private

  def set_package
    @package = packages.find package_id
  end

  def package_id
    vendor_id, package_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id }
  end

  def packages
    Package.configure(config)
  end

  def package_params
    params
      .require(:package)
      .permit(
        :packageName,
        :contentType,
        :isSelected,
        :allowEbscoToAddTitles,
        visibilityData: [:isHidden],
        customCoverage: %i[beginCoverage endCoverage]
      )
  end
end
