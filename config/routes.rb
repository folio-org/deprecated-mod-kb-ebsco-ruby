Rails.application.routes.draw do
  scope '/eholdings' do
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

    resource :configuration, only: [:show, :update]
    resource :status, only: [:show]


  end

  match '/ebsco-rmapi/*path' => 'proxy#index', via: [:get, :post, :put, :patch, :delete]
  match '/admin/health' => 'health#index', via: [:get]
end
