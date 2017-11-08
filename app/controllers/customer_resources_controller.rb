class CustomerResourcesController < ApplicationController
  before_action :configure_resource

  def show
    begin
      vendor_id, package_id, title_id = params[:id].split('-')
      customer_resource = CustomerResource.find(
        vendor_id: vendor_id,
        package_id: package_id,
        title_id: title_id
      )
      render jsonapi: customer_resource,
             include: params[:include]
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  private

  def configure_resource
    CustomerResource.verbose!
    CustomerResource.configure(config)
  end
end
