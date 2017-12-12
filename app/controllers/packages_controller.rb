class PackagesController < ApplicationController
  def index
    @packages = packages.all(q: params[:q])
    render jsonapi: @packages.packagesList.to_a,
           meta: { totalResults: @packages.totalResults }
  end

  def show
    @package = packages.find package_id
    render jsonapi: @package, include: params[:include]
  end

  def update
    @package = packages.find package_id
    @package.update package_params

    render status: :no_content
  end

  private

  def package_id
    vendor_id, package_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id }
  end

  def packages
    Package.configure(config)
  end

  def package_params
    deserialized_params = ActionController::Parameters.new({
      package: DeserializablePackage.new(params[:data].to_unsafe_hash).to_h
    })

    deserialized_params
      .require(:package)
      .permit(
        :isSelected,
        visibilityData: [ :isHidden ],
        customCoverage: [ :beginCoverage, :endCoverage ]
      )
  end
end
