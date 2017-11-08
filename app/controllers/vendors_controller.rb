class VendorsController < ApplicationController
  before_action :configure_resource

  def index
    begin
      vendors = Vendor.all(q: params[:q])
      render jsonapi: vendors.vendors.to_a,
             meta: { totalResults: vendors.totalResults }
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  def show
    begin
      vendor = Vendor.find(params[:id])
      render jsonapi: vendor, include: params[:include]
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  private

  def configure_resource
    Vendor.verbose!
    Vendor.configure(config)
  end
end
