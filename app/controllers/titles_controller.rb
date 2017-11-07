class TitlesController < ApplicationController
  def index
    # Transform query params to what the EBSCO RM-API expects
    query = URI.encode_www_form(
      search: params[:q],
      searchfield: params[:searchfield] || 'titlename',
      orderby: params[:orderby] || params[:q] ? 'relevance' : 'titlename',
      count: params[:count] || 25,
      offset: params[:offset] || 1
    )

    # Make the request for titles from the RM API
    data = rmapi.request(:get, "titles?%{query}" % { query: query })

    if data
      render jsonapi: data.titles.map { |vendor| Title.new(vendor) },
             meta: { totalResults: data.totalResults }
    else
      render jsonapi_errors: rmapi.errors,
             status: rmapi.response.code
    end
  end

  def show
    # Make the request for the title from the RM API
    data = rmapi.request(:get, "titles/%{id}" % { id: params[:id] })

    if data
      render jsonapi: Title.new(data),
             include: params[:include]
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
