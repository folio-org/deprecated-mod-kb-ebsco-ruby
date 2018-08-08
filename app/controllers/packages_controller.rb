# frozen_string_literal: true

class PackagesController < ApplicationController
  deserializable_resource :package, only: %i[create update],
                                    class: DeserializablePackage

  # Please Note below that we use 2 different serializers -
  # SerializablePackageList in the index method and SerializablePackage
  # in other methods. This is a temporary workaround because RM API shows a
  # discrepancy between attributes it provides in a list vs. attributes it
  # provides in a detailed record. When RM API team fixes the issue on their end,
  # we can get rid of the SerializablePackageList class and just use SerializablePackage
  def index
    package_query_params_validation = Validation::PackageQueryParameters.new(params)

    if package_query_params_validation.valid?
      @result = packages.where! params
      render jsonapi: @result.data,
             meta: @result.meta,
             class: { Package: SerializablePackageList }
    else
      render jsonapi_errors: package_query_params_validation.errors,
             status: :bad_request
    end
  end

  def show
    @result = packages.find! params[:id]
    render jsonapi: @result.data, include: params[:include]
  end

  def create
    package_create_validation = Validation::CustomPackageParameters.new(package_create_params)
    if package_create_validation.valid?
      @result = packages.create! package_create_params
      render jsonapi: @result.data
    else
      render jsonapi_errors: package_create_validation.errors,
             status: :unprocessable_entity
    end
  end

  def update
    package_update_validation = Validation::PackageParameters.new(package_update_params)
    if package.is_custom
      package_update_validation = Validation::CustomPackageParameters.new(package_update_params)
    end
    if package_update_validation.valid?
      @result = packages.update! params[:id], package_update_params
      render jsonapi: @result.data
    else
      render jsonapi_errors: package_update_validation.errors,
             status: :unprocessable_entity
    end
  end

  def destroy
    package_destroy_validation = Validation::PackageDestroyParameters.new(package)
    if package_destroy_validation.valid?
      packages.destroy! params[:id]
    else
      render jsonapi_errors: package_destroy_validation.errors,
             status: :bad_request
    end
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
        proxy: %i[id inherited],
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
