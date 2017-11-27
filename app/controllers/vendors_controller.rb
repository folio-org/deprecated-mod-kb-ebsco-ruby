class VendorsController < ApplicationController

  def index
    @vendors = vendors.all(q: params[:q])
    render jsonapi: @vendors.vendors.to_a,
           meta: { totalResults: @vendors.totalResults }
  end

  def show
    @vendor = vendors.find params[:id]
    render jsonapi: @vendor, include: params[:include]
  end

  private

  def vendors
    Vendor.configure config
  end
end
