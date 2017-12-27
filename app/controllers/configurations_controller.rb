# frozen_string_literal: true

class ConfigurationsController < ApplicationController
  def show
    render jsonapi: config
  end

  # TODO: Use ActionController::Parameters
  def update # rubocop:disable Metrics/AbcSize
    data_attributes = JSON.parse(request.body.read)['data']['attributes'] || {}

    config.customer_id = data_attributes['customerId']
    config.api_key = data_attributes['apiKey']

    if config.save
      render jsonapi: config,
             status: :ok
    else
      render jsonapi_errors: config.errors,
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
end
