# frozen_string_literal: true

class ProxyController < ApplicationController
  attr_accessor :rmapi_uri

  before_action :set_rmapi_uri

  def index
    # For the time being, this is a direct passthrough to
    # the EBSCO RM-API.  As more of Codex is incorporated, this will
    # be replaced with more robust serialization.
    response = proxied_response

    render json: response.body,
           status: response.code
  end

  private

  def proxied_response # rubocop:disable Metrics/AbcSize
    # Create the HTTP object
    http = Net::HTTP.new(rmapi_uri.host, rmapi_uri.port)
    http.use_ssl = true

    # Create and send the request
    response = http.send_request(
      request.method,
      rmapi_uri.request_uri,
      request.body.read,
      'X-Api-Key' => config.api_key,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    )

    response
  end

  def set_rmapi_uri
    @rmapi_uri ||= URI(
      format(
        '%{base}/rm/rmaccounts/%{customer_id}%{path}',
        base: rmapi_base_url,
        customer_id: config.customer_id,
        path: rmapi_path
      )
    )
  end

  def rmapi_path
    # What we really care about here is what comes after
    # the `/ebsco-rmapi` namespace.  That's what we proxy to RMAPI
    request.fullpath.gsub(%r{\/ebsco-rmapi}, '')
  end
end
