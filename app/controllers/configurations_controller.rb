class ConfigurationsController < ApplicationController
  def show
    render jsonapi: config
  end

  def update
    begin
      data_attributes = JSON.parse(request.body.read)['data']['attributes'] || {}
    rescue
      error = {
        title: 'Invalid JSON',
        detail: 'The provided JSON payload could not be parsed'
      }

      render jsonapi_errors: [error],
             status: :unprocessable_entity
    end

    config.customer_id = data_attributes['customerId']
    config.api_key = data_attributes['apiKey']

    if config.save
      render jsonapi: config,
             status: :ok
    else
      render jsonapi_errors: config.errors,
             status: :unprocessable_entity
    end
  end
end
