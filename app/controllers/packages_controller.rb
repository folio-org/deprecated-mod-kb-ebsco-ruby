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

  private

  def package_id
    vendor_id, package_id = params[:id].split('-')
    {vendor_id: vendor_id, package_id: package_id }
  end

  def packages
    Package.configure(config)
  end
end
