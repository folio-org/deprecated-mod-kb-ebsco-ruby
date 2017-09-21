Rails.application.routes.draw do
  scope '/eholdings' do
    jsonapi_resource :configuration, only: [:show, :update]
    match '/*path' => 'api#index', via: [:get, :post, :put, :patch, :delete]
  end
end
