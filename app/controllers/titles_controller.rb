class TitlesController < ApplicationController
  before_action :configure_resource

  def index
    begin
      titles = Title.all(q: params[:q])
      render jsonapi: titles.titles.to_a,
             meta: { totalResults: titles.totalResults }
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  def show
    begin
      render jsonapi: Title.find(params[:id]),
             include: params[:include]
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  private

  def configure_resource
    Title.verbose!
    Title.configure(config)
  end
end
