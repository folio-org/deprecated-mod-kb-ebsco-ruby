Rails.application.routes.draw do
  scope '/eholdings' do
    jsonapi_resource :configuration, only: [:show, :update]
    match '/*path' => 'proxy#index', via: [:get, :post, :put, :patch, :delete]
  end
end
