# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :verify_okapi_headers
  before_action :verify_content_type_header
  before_action :set_response_headers
  around_action :catch_exceptions
  around_action :catch_flexirest_exceptions

  def okapi
    @okapi ||= Okapi::Client.new(okapi_url, okapi_tenant, okapi_token)
  end

  def config
    @config ||= ::Configuration.new(okapi, rmapi_base_url).tap(&:load!)
  end

  def rmapi_base_url
    Rails.application.config.rmapi_base_url
  end

  def okapi_url
    request.headers['HTTP_X_OKAPI_URL']
  end

  def okapi_tenant
    request.headers['HTTP_X_OKAPI_TENANT']
  end

  def okapi_token
    request.headers['HTTP_X_OKAPI_TOKEN']
  end

  def content_type
    request.headers['Content-Type']
  end

  private

  def catch_exceptions
    yield
  rescue ActionController::BadRequest => e
    render jsonapi_errors: { "title": e.message },
           status: :bad_request
  end

  def catch_flexirest_exceptions
    yield
  rescue Flexirest::HTTPClientException,
         Flexirest::HTTPServerException,
         Flexirest::HTTPNotFoundClientException => e

    render jsonapi_errors: get_errors_hash(e),
           status: e.status
  end

  def get_errors_hash(e) # rubocop:disable Metrics/AbcSize
    if e.result.respond_to?(:Errors)
      e.result.Errors.to_a.map do |err|
        { "title": map_provider(err.to_hash['Message']) }
      end
    elsif e.result.respond_to?(:errors)
      e.result[:errors].items.to_a.map do |err|
        { "title": map_provider(err.to_hash['message']) }
      end
    else
      []
    end
  end

  def map_provider(string)
    string.gsub(/Vendor/, 'Provider').gsub(/vendor/, 'provider')
  end

  def verify_okapi_headers
    if !okapi_url
      render plain: 'Missing header X-OKAPI-URL', status: :bad_request
    elsif !okapi_tenant
      render plain: 'Missing header X-OKAPI-TENANT', status: :bad_request
    elsif !okapi_token
      render plain: 'Missing header X-OKAPI-TOKEN', status: :bad_request
    end
  end

  def verify_content_type_header
    render plain: 'Missing/Invalid header Content-Type', status: :bad_request if !content_type || content_type != 'application/vnd.api+json'
  end

  def set_response_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end
end
