Rails.application.routes.draw do
  scope '/eholdings' do
    scope '/jsonapi' do

      resources :vendors, only: [:index, :show] do
        member do
          get 'packages'
        end
      end

      resources :packages, only: [:index, :show, :update] do
        member do
          get 'customer-resources'
        end
      end

      resources :titles, only: [:index, :show] do
        member do
          get 'customer-resources'
        end
      end

      resources :customer_resources, :path => '/customer-resources', only: [:show, :update]
    end

    resource :configuration, only: [:show, :update]
    resource :status, only: [:show]
    match '/*path' => 'proxy#index', via: [:get, :post, :put, :patch, :delete]
  end

  match '/admin/health' => 'health#index', via: [:get]
end
