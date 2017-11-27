class CustomerResourcesController < ApplicationController
  def show
    @customer_resource = customer_resources.find customer_resource_id
    render jsonapi: @customer_resource, include: params[:include]
  end

  private

  def customer_resource_id
    vendor_id, package_id, title_id = params[:id].split('-')
    { vendor_id: vendor_id, package_id: package_id, title_id: title_id }
  end

  def customer_resources
    CustomerResource.configure config
  end
end
