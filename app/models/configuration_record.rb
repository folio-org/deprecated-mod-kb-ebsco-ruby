class ConfigurationRecord < ApplicationModel
  attr_accessor :customer_id, :api_key

  validates :customer_id, :presence => true
  validates :api_key, :presence => true
end
