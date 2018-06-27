# frozen_string_literal: true

class ProvidersController < ApplicationController
  before_action :set_provider, only: %i[show update packages]

  deserializable_resource :provider, only: :update,
                                     class: DeserializableProvider

  # Please Note below that we use 2 different serializers -
  # SerializableProviderList in the index method and SerializableProvider
  # in other methods. This is a temporary workaround because RM API shows a
  # discrepancy between attributes it provides in a list vs. attributes it
  # provides in a detailed record. When RM API team fixes the issue on their end,
  # we can get rid of the SerializableProviderList class and just use SerializableProvider
  def index
    provider_query_params_validation = Validation::ProviderQueryParameters.new(params)

    if provider_query_params_validation.valid?
      @providers = providers.all(
        q: params[:q],
        page: params[:page],
        sort: params[:sort]
      )

      render jsonapi: @providers.vendors.to_a,
             meta: { totalResults: @providers.totalResults },
             class: { Provider: SerializableProviderList }
    else
      render jsonapi_errors: provider_query_params_validation.errors,
             status: :bad_request
    end
  end

  def show
    render jsonapi: @provider,
           include: params[:include]
  end

  def update
    provider_validation = Validation::ProviderParameters.new(provider_params)

    if provider_validation.valid?
      @provider.update provider_params
      render jsonapi: @provider
    else
      render jsonapi_errors: provider_validation.errors,
             status: :unprocessable_entity
    end
  end

  # Relationships
  def packages
    @packages = @provider.find_packages(
      q: params[:q],
      page: params[:page],
      filter: params[:filter],
      sort: params[:sort]
    )

    render jsonapi: @packages.data,
           meta: @packages.meta
  end

  private

  def set_provider
    @provider = providers.find params[:id]
  end

  def providers
    Provider.configure config
  end

  def provider_params
    params
      .require(:provider)
      .permit(
        vendorToken: [:value],
        proxy: [:id]
      )
  end
end
