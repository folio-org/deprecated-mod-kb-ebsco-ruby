class VendorsController < ApplicationController
  before_action :configure_resource

  def index
    vendors = Vendor.all(q: params[:q])
    render jsonapi: vendors.vendors.to_a,
           meta: { totalResults: vendors.totalResults }
  end

  def show
    render jsonapi: Vendor.find(params[:id]),
           include: params[:include]
  end

  private

  def configure_resource
    Vendor.verbose!
    Vendor.configure(config)
  end
end
