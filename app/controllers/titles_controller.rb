# frozen_string_literal: true

class TitlesController < ApplicationController
  before_action :set_title, only: %i[show resources]

  # Please Note below that we use 2 different serializers -
  # SerializableTitleList in the index method and SerializableTitle
  # in other methods. This is a temporary workaround because RM API shows a
  # discrepancy between attributes it provides in a list vs. attributes it
  # provides in a detailed record. When RM API team fixes the issue on their end,
  # we can get rid of the SerializableTitleList class and just use SerializableTitle
  def index
    title_query_params_validation = Validation::TitleQueryParameters.new(params)

    if title_query_params_validation.valid?
      @titles = titles.all(
        q: params[:q],
        page: params[:page],
        filter: params[:filter],
        sort: params[:sort],
        count: params[:count]
      )

      render jsonapi: @titles.titles.to_a,
             meta: { totalResults: @titles.totalResults },
             class: { Title: SerializableTitleList }
    else
      render jsonapi_errors: title_query_params_validation.errors,
             status: :bad_request
    end
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
      fail ActionController::BadRequest, 'Missing resource'
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
