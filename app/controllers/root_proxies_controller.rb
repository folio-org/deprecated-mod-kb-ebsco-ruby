# frozen_string_literal: true

class RootProxiesController < ApplicationController
  deserializable_resource :root_proxy, only: [:update],
                                       class: DeserializableRootProxy

  def show
    @result = root_proxy.find!
    render jsonapi: @result.data
  end

  def update
    proxy_types_list = ProxyTypesRepository.new(config: config).all!
    proxy_id = root_proxy_update_params[:proxyTypeId]
    root_proxy_validation = Validation::RootProxyParameters.new(proxy_id, proxy_types_list.data)

    if root_proxy_validation.valid?
      @result = root_proxy.update! root_proxy_update_params
      render jsonapi: @result.data
    else
      render jsonapi_errors: root_proxy_validation.errors,
             status: :unprocessable_entity
    end
  end

  private

  def root_proxy_params
    params
      .fetch(:root_proxy, {})
      .permit(
        :proxyTypeId
      )
  end

  def root_proxy_update_params
    root_proxy_params
  end

  def root_proxy
    RootProxiesRepository.new(config: config)
  end
end
