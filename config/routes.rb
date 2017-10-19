Rails.application.routes.draw do
  scope '/eholdings' do
    jsonapi_resource :configuration, only: [:show, :update]
    jsonapi_resource :status, only: [:show]
    match '/*path' => 'proxy#index', via: [:get, :post, :put, :patch, :delete]
  end
end
