# frozen_string_literal: true

class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[show packages]

  def index
    @providers = providers.all(
      q: params[:q],
      page: params[:page],
      sort: params[:sort]
    )

    render jsonapi: @providers.vendors.to_a,
           meta: { totalResults: @providers.totalResults }
  end

  def show
    render jsonapi: @provider, include: params[:include]
  end

  # Relationships
  def packages
    @packages = @provider.find_packages(page: params[:page])
    render jsonapi: @packages.packagesList.to_a,
           meta: { totalResults: @packages.totalResults }
  end

  private

  def set_provider
    @provider = providers.find params[:id]
  end

  def providers
    Provider.configure config
  end
end
