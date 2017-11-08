class TitlesController < ApplicationController
  before_action :configure_resource

  def index
    titles = Title.all(q: params[:q])
    render jsonapi: titles.titles.to_a,
           meta: { totalResults: titles.totalResults }
  end

  def show
    render jsonapi: Title.find(params[:id]),
           include: params[:include]
  end

  private

  def configure_resource
    Title.verbose!
    Title.configure(config)
  end
end
