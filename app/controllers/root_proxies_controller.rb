# frozen_string_literal: true

class RootProxiesController < ApplicationController
  def index
    render jsonapi: root_proxies.all, include: params[:include]
  end

  def update # rubocop:disable Metrics/AbcSize
    data_attributes = JSON.parse(request.body.read)['data']['attributes'] || {}
    root_proxy_id = params[:id]

    root_proxy_validation =
      Validation::RootProxyParameters.new(data_attributes,
                                          root_proxy_id,
                                          root_proxies.all)

    if root_proxy_validation.valid?
      @root_proxy = root_proxies.update(
        data_attributes
      )
      render jsonapi: @root_proxy
    else
      render jsonapi_errors: root_proxy_validation.errors,
             status: :unprocessable_entity
    end
  # NoMethodError is raised when [] is invoked on 'data' or
  # `data_attributes` and they are `nil`
  rescue JSON::ParserError, NoMethodError
    error = {
      title: 'Invalid JSON',
      detail: 'The provided JSON payload could not be parsed'
    }

    render jsonapi_errors: [error],
           status: :unprocessable_entity
  end

  private

  def root_proxies
    RootProxy.configure config
  end
end
