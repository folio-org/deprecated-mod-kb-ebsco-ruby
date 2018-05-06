# frozen_string_literal: true

class TitlesController < ApplicationController
  before_action :set_title, only: %i[show resources]

  def index
    @titles = titles.all(
      q: params[:q],
      page: params[:page],
      filter: params[:filter],
      sort: params[:sort]
    )

    render jsonapi: @titles.titles.to_a,
           meta: { totalResults: @titles.totalResults }
  end

  def create
    # RM API creates titles as a side-effect of creating resources, so
    # we validate against a resource using the combined payload of the
    # new title and an included resource with a packageId
    resource_validation =
      Validation::ResourceCreateParameters.new(combined_resource)

    if resource_validation.valid?
      @title = titles.create_title(combined_resource)
      render jsonapi: @title
    else
      render jsonapi_errors: resource_validation.errors,
             status: :unprocessable_entity
    end
  # combined_resource may raise this exception
  rescue JSON::ParserError, NoMethodError
    error = {
      title: 'Invalid JSON',
      detail: 'The provided JSON payload could not be parsed'
    }

    render jsonapi_errors: [error],
           status: :unprocessable_entity
  end

  def show
    render jsonapi: @title, include: params[:include]
  end

  # Relationships
  def resources
    render jsonapi: @title.resources
  end

  private

  def set_title
    @title = titles.find params[:id]
  end

  def titles
    Title.configure(config)
  end

  def combined_resource
    json = JSON.parse request.body.read

    unless json['included']&.first
      raise ActionController::BadRequest, 'Missing resource'
    end

    resource_params = json['data']['attributes'].merge(
      json['included'].first['attributes']
    )

    DeserializableResource.call(
      'type' => 'resources',
      'attributes' => resource_params
    )
  end
end
