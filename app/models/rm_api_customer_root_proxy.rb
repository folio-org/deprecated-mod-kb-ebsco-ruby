# frozen_string_literal: true

class RmApiCustomerRootProxy < RmApiResource
  request_body_type :json

  get :all, '/proxies'
end
