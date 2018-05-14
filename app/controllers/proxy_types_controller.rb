# frozen_string_literal: true

class ProxyTypesController < ApplicationController
  def index
    @result = proxy_types.where!
    render jsonapi: @result.data
  end

  def proxy_types
    ProxyTypesRepository.new(config: config)
  end
end
