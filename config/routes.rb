Rails.application.routes.draw do
  match '*path' => 'api#index', via: [:get, :post, :put, :patch, :delete]
end
