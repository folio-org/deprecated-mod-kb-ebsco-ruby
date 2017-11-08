class CustomerResourcesController < ApplicationController

  def show
    vendor_id, package_id, title_id = params[:id].split('-')

    customer_resource_path = "vendors/%{vendor_id}/packages/%{package_id}/titles/%{title_id}" % {
      vendor_id: vendor_id || 0,
      package_id: package_id || 0,
      title_id: title_id || 0
    }
    # Make the request for the title from the RM API
    response = rmapi.request(:get, customer_resource_path)

    if response.ok?
      render jsonapi: CustomerResource.new(title_data: response.data),
             include: params[:include]
    else
      render jsonapi_errors: response.errors,
             status: response.code
    end
  end

  private

  def rmapi
    RmApiService.new(
      base_url: rmapi_base_url,
      customer_id: config.customer_id,
      api_key: config.api_key
    )
  end
end
