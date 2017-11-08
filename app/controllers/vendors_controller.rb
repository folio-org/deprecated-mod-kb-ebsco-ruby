class VendorsController < ApplicationController
  def index
    # Transform query params to what the EBSCO RM-API expects
    query = URI.encode_www_form(
      search: params[:q],
      orderby: params[:orderby] || params[:q] ? 'relevance' : 'vendorname',
      count: params[:count] || 25,
      offset: params[:offset] || 1
    )

    # Make the request for vendors from the RM API
    response = rmapi.request(:get, "vendors?%{query}" % { query: query })

    if response.ok?
      render jsonapi: response.data.vendors.map { |vendor| Vendor.new(vendor) },
             meta: { totalResults: response.data.totalResults }
    else
      render jsonapi_errors: response.errors,
             status: response.code
    end
  end

  def show
    # Make the request for the vendor from the RM API
    response = rmapi.request(:get, "vendors/%{id}" % { id: params[:id] })

    if response.ok?
      render jsonapi: Vendor.new(response.data)
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
