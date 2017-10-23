class StatusesController < ApplicationController
  def show
    config = ::Configuration.new(okapi, rmapi_base_url)
    config.load!

    status = Status.new(config)

    render jsonapi: status,
           status: :ok
  end
end
