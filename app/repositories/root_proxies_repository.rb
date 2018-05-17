# frozen_string_literal: true

class RootProxiesRepository
  attr_reader :base_url, :headers

  def initialize(config:)
    @config = config
    @base_url = "#{rmapi_url}/rm/rmaccounts/#{config.customer_id}"

    @headers = {
      'X-Api-Key': config.api_key,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  def find!
    request do
      status, body = rmapi(:get, '')
      Result.new(
        data: to_root_proxy(body[:proxy]),
        status: status
      )
    end
  end

  def update!(attrs)
    request do
      payload = attrs.to_hash.deep_symbolize_keys

      # if you update a root-proxy independently with sending the
      # custom-labels along all the custom if any will be erased.
      # so we need to get the custom labels and post those along
      # with the root-proxy
      payload[:proxy] = { id: payload.delete(:proxyTypeId) }

      rmapi(:put, '', json: payload)

      status, body = rmapi(:get, '')
      Result.new(data: to_root_proxy(body[:proxy]), status: status)
    end
  end

  private

  # superclass for repository errors
  class RepositoryError < StandardError; end

  # the request can't be made because something is wrong with it
  class BadRequest < RepositoryError; end

  # the request was made, but it failed
  class RequestError < RepositoryError
    attr_reader :result
    def initialize(result)
      super result.message
      @result = result
    end
  end

  # TODO: split into Success and Error subclasses
  class Result
    attr_reader :data, :status

    def initialize(data:, status:)
      @data = data
      @status = status
    end

    def return!
      fail RequestError, self unless success?
      self
    end

    delegate :success?, to: :status
  end

  def rmapi(verb, fragment, **options)
    response = HTTP.headers(headers).request(verb, "#{base_url}#{fragment}", options)
    [response.status, normalize_response_body(response)]
  end

  def rmapi_url
    Rails.application.config.rmapi_base_url
  end

  def normalize_response_body(response)
    body = response.body.to_s
    return unless body.length.positive?
    JSON.parse(response.body.to_s).deep_transform_keys { |key| key.underscore.to_sym }
  end

  def to_root_proxy(hash)
    RootProxy.new(id: 'eholdings/root-proxy', proxy_type_id: hash[:id])
  end

  def request
    yield.return!
  end
end
