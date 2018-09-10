# frozen_string_literal: true

class ProxyTypesRepository < RmapiRepository
  def all!
    where!
  end

  def where!
    status, body = rmapi(:get, '/proxies')
    Result.new(
      data: body.map { |hash| to_proxy_type hash },
      status: status
    )
  end

  private

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

  def normalize_response_body(response)
    body = response.body.to_s
    return unless body.length.positive?
    JSON.parse(response.body.to_s).map { |proxy| proxy.deep_transform_keys { |key| key.underscore.to_sym } }
  end

  def to_proxy_type(hash)
    ProxyType.new(hash)
  end
end
