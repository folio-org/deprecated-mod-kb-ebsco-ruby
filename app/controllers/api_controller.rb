require 'net/http'

class ApiController < ApplicationController
  def index
    # Form the URL
    urlstr = "#{ENV['EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL']}/rm/rmaccounts/#{ENV['EBSCO_RESOURCE_MANAGEMENT_API_CUSTOMER_ID']}#{request.fullpath}"
    uri = URI(urlstr)

    # Create the HTTP object
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Create the request
    external_request = Net::HTTP::Get.new(uri.request_uri)
    external_request["Accept"] = 'application/json'
    external_request["X-Api-Key"] = ENV['EBSCO_RESOURCE_MANAGEMENT_API_KEY']

    # Send the request
    response = http.request(external_request)
    render :json => response.body
  end
end
