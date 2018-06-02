# frozen_string_literal: true

class ProxyTypesController < ApplicationController
  def index
    @result = proxy_types.all!
    render jsonapi: @result.data
  end

  def proxy_types
    ProxyTypesRepository.new(config: config)
  end
end
