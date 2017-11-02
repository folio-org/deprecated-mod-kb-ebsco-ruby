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
    data = rmapi.request(:get, "vendors?%{query}" % { query: query })

    if data
      render jsonapi: data.vendors.map { |vendor| Vendor.new(vendor) },
             meta: { totalResults: data.totalResults }
    else
      render jsonapi_errors: rmapi.errors,
             status: rmapi.response.code
    end
  end

  def show
    # Make the request for the vendor from the RM API
    data = rmapi.request(:get, "vendors/%{id}" % { id: params[:id] })

    if data
      render jsonapi: Vendor.new(data)
    else
      render jsonapi_errors: rmapi.errors,
             status: rmapi.response.code
    end
  end

  private

  def rmapi
    @rmapi ||= ::RmApiService.new(
      base_url: rmapi_base_url,
      customer_id: config.customer_id,
      api_key: config.api_key
    )
  end
end
