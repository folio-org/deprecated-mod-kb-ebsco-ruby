class PackagesController < ApplicationController

  before_action :set_package, only: [:show, :update, :customer_resources]

  deserializable_resource :package, only: :update

  def index
    @packages = packages.all(q: params[:q], page: params[:page])
    render jsonapi: @packages.packagesList.to_a,
           meta: { totalResults: @packages.totalResults }
  end

  def show
    render jsonapi: @package, include: params[:include]
  end

  def update
    @package.update package_params
    render jsonapi: @package
  end

  # Relationships
  def customer_resources
    render jsonapi: @package.customer_resources
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
        :isSelected,
        visibilityData: [ :isHidden ],
        customCoverage: [ :beginCoverage, :endCoverage ]
      )
  end
end
