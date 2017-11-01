class VendorsController < ApplicationController
  def index
    uri = URI(rmapi_path)

    # Transform query params to what the EBSCO RM-API expects
    uri.query = URI.encode_www_form(
      search: params[:q],
      orderby: params[:orderby] || params[:q] ? 'relevance' : 'vendorname',
      count: params[:count] || 25,
      offset: params[:offset] || 1
    )

    # Make the RM-API request and parse the response body
    response = get_resource(uri)
    data = Map JSON.parse(response.body)

    # Return the list of vendors
    if response.message === 'OK'
      vendors = data.vendors.map do |vendor|
        Vendor.new(vendor)
      end

      render jsonapi: vendors,
             meta: { totalResults: data.totalResults },
             status: :ok
    else
      render_rmapi_errors(data, response.code)
    end
  end

  def show
    uri = URI(
      "#{rmapi_path}/%{vendor_id}" % {
        vendor_id: params[:id]
      }
    )

    # Make the RM-API request and parse the response body
    response = get_resource(uri)
    data = Map JSON.parse(response.body)

    # Return the requested vendor
    if response.message === 'OK'
      vendor = Vendor.new(data)
      render jsonapi: vendor, status: :ok
    else
      render_rmapi_errors(data, response.code)
    end
  end

  def get_resource(uri)
    # Create the HTTP object
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Create and send the request
    http.get(
      uri.request_uri,
      {
        "X-Api-Key" => config.api_key,
        "Content-Type" => 'application/json',
        "Accept" => 'application/json'
      }
    )
  end

  def render_rmapi_errors(data, code)
    # Map RMAPI errors to JSON-API error objects
    jsonapi_errors = data.Errors.map { |err| { title: err.Message } }
    render jsonapi_errors: jsonapi_errors, status: code
  end

  def rmapi_path
    "%{base}/rm/rmaccounts/%{customer_id}/vendors" % {
      base: rmapi_base_url,
      customer_id: config.customer_id
    }
  end
end
