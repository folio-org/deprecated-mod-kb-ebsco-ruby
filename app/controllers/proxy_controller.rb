class ProxyController < ApplicationController
  def configuration
    @config ||= ::Configuration.new(okapi).tap do |config|
      config.load!
    end
  end

  def index
    # This is currently just a passthrough to the RM-API

    # Form the URL
    urlstr = "#{ENV['EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL']}/rm/rmaccounts/#{configuration.customer_id}#{request.fullpath}"
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
        "X-Api-Key" => configuration.api_key,
        "Content-Type" => 'application/json',
        "Accept" => 'application/json'
      }
    )

    render :json => response.body, :status => response.code
  end
end
