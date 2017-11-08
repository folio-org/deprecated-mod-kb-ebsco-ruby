class PackagesController < ApplicationController
  before_action :configure_resource

  def index
    packages = Package.all(q: params[:q])
    render jsonapi: packages.packagesList.to_a,
           meta: { totalResults: packages.totalResults }
  end

  def show
    vendor_id, package_id = params[:id].split('-')
    render jsonapi: Package.find(vendor_id: vendor_id, package_id: package_id),
           include: params[:include]
  end

  private

  def configure_resource
    Package.verbose!
    Package.configure(config)
  end
end
