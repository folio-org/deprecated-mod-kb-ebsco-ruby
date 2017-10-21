class ProxyController < ApplicationController
  def index
    # For the time being, this is a direct passthrough to
    # the EBSCO RM-API.  As more of Codex is incorporated, this will
    # be replaced with more robust serialization.
    uri = URI(
      "%{base}/rm/rmaccounts/%{customer_id}%{path}" % {
        base: rmapi_base_url,
        customer_id: configuration.customer_id,
        path: rmapi_path
      }
    )

    # Create the HTTP object
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Create and send the request
    response = http.send_request(
      request.method,
      uri.request_uri,
      request.body.read,
      {
        "X-Api-Key" => configuration.api_key,
        "Content-Type" => 'application/json',
        "Accept" => 'application/json'
      }
    )

    render :json => response.body, :status => response.code
  end

  private

  def rmapi_path
    # What we really care about here is what comes after
    # the `/eholdings` namespace.  That's what we proxy to RMAPI
    request.fullpath.gsub(/\/eholdings/, '')
  end

  def configuration
    @config ||= ::Configuration.new(okapi, rmapi_base_url).tap do |config|
      config.load!
    end
  end
end
