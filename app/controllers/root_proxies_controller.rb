# frozen_string_literal: true

class RootProxiesController < ApplicationController
  def show
    @result = root_proxy.find!
    render :jsonapi, @result.data
  end

  def update
    @result = root_proxy.update! update_params
    render status: :no_content
  end

  private

  def update_params
    params
  end

  def root_proxy
    RootProxyRepository.new configure
  end
end
