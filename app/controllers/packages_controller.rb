class PackagesController < ApplicationController
  before_action :configure_resource

  def index
    begin
      packages = Package.all(q: params[:q])
      render jsonapi: packages.packagesList.to_a,
             meta: { totalResults: packages.totalResults }
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  def show
    begin
      vendor_id, package_id = params[:id].split('-')
      pkg = Package.find(vendor_id: vendor_id, package_id: package_id)
      render jsonapi: pkg, include: params[:include]
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  private

  def configure_resource
    Package.verbose!
    Package.configure(config)
  end
end
