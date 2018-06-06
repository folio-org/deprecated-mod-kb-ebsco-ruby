# frozen_string_literal: true

class RootProxiesRepository < RmapiRepository
  def find!
    status, body = request(:get, '')
    Result.new(
      data: to_root_proxy(body[:proxy]),
      status: status
    )
  end

  def update!(attrs)
    payload = attrs.to_hash.deep_symbolize_keys

    # if you update a root-proxy independently with sending the
    # custom-labels along all the custom if any will be erased.
    # so we need to get the custom labels and post those along
    # with the root-proxy

    _, custom_label_body = request(:get, '')

    cleaned = custom_label_body[:labels].reject { |n| n[:display_label] == '' }
                                        .map { |n| n.deep_transform_keys { |key| key.to_s.camelize(:lower) } }

    payload[:proxy] = { id: payload.delete(:proxyTypeId) }
    payload[:labels] = cleaned

    request(:put, '', json: payload)

    status, body = request(:get, '')
    Result.new(data: to_root_proxy(body[:proxy]), status: status)
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

  def normalize_response_body(response)
    body = response.body.to_s
    return unless body.length.positive?
    JSON.parse(response.body.to_s).deep_transform_keys { |key| key.underscore.to_sym }
  end

  def to_root_proxy(hash)
    RootProxy.new(id: 'root-proxy', proxy_type_id: hash[:id])
  end
end
