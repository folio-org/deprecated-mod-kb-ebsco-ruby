# frozen_string_literal: true

class RmapiRepository
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

  def request(verb, fragment = '', **options)
    ## Construction of url is different based on whether fragment is present or not because
    ## RM API in sandbox needs a trailing slash when fragment is not present.
    ## As of 08/08/2018, it gives a 403 otherwise.
    url = fragment == '' ? "#{base_url}/" : "#{base_url}#{fragment}"
    response = HTTP.headers(headers).request(
      verb,
      url,
      options
    )

    fail RequestError.new(response.body, response.status) unless response.status.success?

    # TODO: return Result instance, nix normalize_response_body and make it to_entity
    # enforce generic interface
    [response.status, normalize_response_body(response)]
  end

  private

  def rmapi_url
    Rails.application.config.rmapi_base_url
  end

  class RequestError < StandardError
    attr_reader :status

    def initialize(message, status)
      @status = status
      super(message)
    end
  end
end

# TODO: abstract methods?
