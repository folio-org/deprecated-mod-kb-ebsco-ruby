class StatusesController < ApplicationController
  def show
    status = Status.new(config)
    render jsonapi: status
  end
end
