Rails.application.routes.draw do
  scope '/eholdings' do
    scope '/jsonapi' do
      resources :vendors, only: [:index, :show]
      resources :packages, only: [:index, :show]
      resources :titles, only: [:index, :show]
      resources :customer_resources, :path => '/customer-resources', only: [:show]
    end

    resource :configuration, only: [:show, :update]
    resource :status, only: [:show]
    match '/*path' => 'proxy#index', via: [:get, :post, :put, :patch, :delete]
  end

  match '/admin/health' => 'health#index', via: [:get]
end
