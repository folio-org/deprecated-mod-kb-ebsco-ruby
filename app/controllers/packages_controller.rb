class PackagesController < ApplicationController
  def index
    # Transform query params to what the EBSCO RM-API expects
    query = URI.encode_www_form(
      search: params[:q],
      orderby: params[:orderby] || params[:q] ? 'relevance' : 'packagename',
      count: params[:count] || 25,
      offset: params[:offset] || 1
    )

    # Make the request for packages from the RM API
    response = rmapi.request(:get, "packages?%{query}" % { query: query })

    if response.ok?
      render jsonapi: response.data.packagesList.map { |package| Package.new(data: package) },
             meta: { totalResults: response.data.totalResults }
    else
      render jsonapi_errors: response.errors,
             status: response.code
    end
  end

  def show
    # The package id is a composite of the vendor id since package
    # resources are nested within vendors
    vendor_id, package_id = params[:id].split('-')
    included_resources = params[:include] ? params[:include].split(',') : []
    pending_requests = {}

    package_path = "vendors/%{vendor_id}/packages/%{package_id}" % {
      vendor_id: vendor_id || 0,
      package_id: package_id || 0
    }
    pending_requests[:package] = [:get, package_path]

    if included_resources.include?('customerResources')
      package_titles_path = "#{package_path}/titles?%{query}" % {
        # Required RM API params
        query: URI.encode_www_form(
          search: '',
          searchfield: 'titlename',
          orderby: 'titlename',
          count: 25,
          offset: 1
        )
      }
      pending_requests[:titles] = [:get,  package_titles_path]
    end

    # This is a 'compound' request, consisting of multiple calls
    # to the RMAPI. `request_multi` will process each request
    # in the pending_requests object and return the responses
    # in a similar data structure
    responses = rmapi.request_multi(pending_requests)

    if responses.ok?
      titles = responses.titles.data.titles rescue []
      render jsonapi: Package.new(data: responses.package.data, titles: titles),
             include: params[:include]
    else
      render jsonapi_errors: responses.errors,
             status: responses.code
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
