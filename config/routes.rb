Rails.application.routes.draw do
  scope '/eholdings' do
    resource :configuration, only: [:show, :update]
    resource :status, only: [:show]
    match '/*path' => 'proxy#index', via: [:get, :post, :put, :patch, :delete]
  end

  match '/admin/health' => 'health#index', via: [:get]
end
