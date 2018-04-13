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

    resources :packages, only: %i[index show update] do
      member do
        get 'resources'
      end
    end

    resources :titles, only: %i[index show] do
      member do
        get 'resources'
      end
    end

    resources :resources,
              path: '/resources',
              only: %i[show update]

    resources :custom_labels,
              path: '/custom-labels',
              only: %i[index update destroy]

    resources :root_proxies,
              path: '/root-proxies',
              only: %i[index update]

    resource :configuration, only: %i[show update]
    resource :status, only: [:show]
  end

  match '/ebsco-rmapi/*path' => 'proxy#index',
        via: %i[get post put patch delete]

  match '/admin/health' => 'health#index',
        via: [:get]
end
