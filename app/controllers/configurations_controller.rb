class ConfigurationsController < ApplicationController
  def show
    config = ::Configuration.new(okapi, rmapi_base_url)
    config.load!

    render jsonapi: config
  end

  def update
    config = ::Configuration.new(okapi, rmapi_base_url)

    begin
      data_attributes = JSON.parse(request.body.read)['data']['attributes'] || {}
    rescue
      error = [
        {
          title: 'Invalid JSON',
          detail: 'The provided JSON payload could not be parsed'
        }
      ]
      render jsonapi_errors: [ error ],
             status: :unprocessable_entity
    end

    config.customer_id = data_attributes['customer-id']
    config.api_key = data_attributes['api-key']


    if config.save
      render jsonapi: config,
             status: :ok
    else
      render jsonapi_errors: config.errors,
             status: :unprocessable_entity
    end
  end
end
