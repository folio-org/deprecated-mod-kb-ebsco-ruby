# frozen_string_literal: true

require 'open-uri'

class Configuration
  include ActiveModel::Validations

  attr_accessor :customer_id, :api_key, :rmapi_base_url

  validate :verify_credentials

  def id
    'configuration'
  end

  def initialize(okapi)
    @okapi = okapi
  end

  def load!
    response = @okapi.user.get '/configurations/entries?query=module=EKB'
    response['configs'].each do |config|
      if config['code'].casecmp?('kb.ebsco.customerid')
        @customer_id = config['value']
      elsif config['code'].casecmp?('kb.ebsco.apikey')
        @api_key = config['value']
      elsif config['code'].casecmp?('kb.ebsco.url')
        @rmapi_base_url = config['value']
      end
    end
  end

  def verify_credentials
    verify_path = 'vendors?search=zz12&offset=1&orderby=vendorname&count=1'

    response = RmApiService.new(
      base_url: @rmapi_base_url,
      customer_id: @customer_id,
      api_key: @api_key
    ).request(:get, verify_path)

    return true if response.ok?
    errors.add('KB API Credentials', 'are invalid')
  end

  def save
    return false unless valid?

    response = @okapi.user.get '/configurations/entries?query=module=EKB'

    response['configs'].each do |config|
      if ['kb.ebsco.customerid', 'kb.ebsco.apikey', 'kb.ebsco.url'].include? config['code'].downcase
        id = config['id']
        @okapi.user.delete "/configurations/entries/#{id}"
      end
    end

    @okapi.user.post(
      '/configurations/entries',
      "module": 'EKB',
      "configName": 'api_access',
      "code": 'kb.ebsco.url',
      "description": 'EBSCO RM-API URL',
      "enabled": true,
      "value": @rmapi_base_url
    )

    @okapi.user.post(
      '/configurations/entries',
      "module": 'EKB',
      "configName": 'api_access',
      "code": 'kb.ebsco.customerId',
      "description": 'EBSCO RM-API Customer ID',
      "enabled": true,
      "value": @customer_id
    )

    @okapi.user.post(
      '/configurations/entries',
      "module": 'EKB',
      "configName": 'api_access',
      "code": 'kb.ebsco.apiKey',
      "description": 'EBSCO RM-API API Key',
      "enabled": true,
      "value": @api_key
    )
  end
end
