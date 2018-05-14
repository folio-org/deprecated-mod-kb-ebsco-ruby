# frozen_string_literal: true

class ProxyType
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :url_mask
end
