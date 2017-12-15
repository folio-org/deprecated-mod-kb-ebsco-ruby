class TitlesController < ApplicationController

  def index
    @titles = titles.all(q: params[:q], page: params[:page])
    render jsonapi: @titles.titles.to_a,
           meta: { totalResults: @titles.totalResults }
  end

  def show
    render jsonapi: titles.find(params[:id]),
           include: params[:include]
  end

  private

  def titles
    Title.configure(config)
  end
end
