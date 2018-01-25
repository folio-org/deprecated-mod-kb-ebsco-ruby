# frozen_string_literal: true

class TitlesController < ApplicationController
  before_action :set_title, only: %i[show customer_resources]

  def index
    @titles = titles.all(
      q: params[:q],
      page: params[:page],
      filter: params[:filter]
    )

    render jsonapi: @titles.titles.to_a,
           meta: { totalResults: @titles.totalResults }
  end

  def show
    render jsonapi: @title, include: params[:include]
  end

  # Relationships
  def customer_resources
    render jsonapi: @title.customer_resources
  end

  private

  def set_title
    @title = titles.find params[:id]
  end

  def titles
    Title.configure(config)
  end
end
