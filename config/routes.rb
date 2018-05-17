# frozen_string_literal: true

Rails.application.routes.draw do
  scope '/eholdings' do
    resources :vendors, only: %i[index show] do
      member do
        get 'packages'
      end
    end

    resources :providers, only: %i[index show update] do
      member do
        get 'packages'
      end
    end

    resources :packages, only: %i[create index show update destroy] do
      member do
        get 'resources'
      end
    end

    resources :titles, only: %i[index create show] do
      member do
        get 'resources'
      end
    end

    resources :resources,
              path: '/resources',
              only: %i[create show update destroy]

    resources :custom_labels,
              path: '/custom-labels',
              only: %i[index update destroy]

    resources :proxy_types,
              path: 'proxy-types',
              only: [:index]

    resource :root_proxy,
             path: 'root-proxy',
             only: %i[show update]

    resource :configuration, only: %i[show update]
    resource :status, only: [:show]
  end

  match '/ebsco-rmapi/*path' => 'proxy#index',
        via: %i[get post put patch delete]

  match '/admin/health' => 'health#index',
        via: [:get]
end
