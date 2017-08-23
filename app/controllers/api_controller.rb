require 'net/http'

class ApiController < ApplicationController
  def index
    # Form the URL
    urlstr = "#{ENV['EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL']}/rm/rmaccounts/#{ENV['EBSCO_RESOURCE_MANAGEMENT_API_CUSTOMER_ID']}#{request.fullpath}"
    urlstr.slice! '/eholdings'
    uri = URI(urlstr)

    # Create the HTTP object
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Create and send the request
    response = http.send_request(
        request.method,
        uri.request_uri,
        request.body.read(),
        {
            "X-Api-Key" => ENV['EBSCO_RESOURCE_MANAGEMENT_API_KEY'],
            "Content-Type" => 'application/json',
            "Accept" => 'application/json'
        }
    )

    render :json => response.body, :status => response.code
  end
end
