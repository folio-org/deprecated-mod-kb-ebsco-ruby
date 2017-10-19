require "open-uri"

class Configuration
  attr_reader :errors
  attr_accessor :customer_id, :api_key

  def initialize(okapi)
    @errors = {}
    @okapi = okapi
  end

  def load!
    response = @okapi.user.get '/configurations/entries?query=module=KB_EBSCO'
    response["configs"].each do |config|
      params = Rack::Utils.parse_query(config["value"])
      self.customer_id = params["customer-id"]
      self.api_key = params["api-key"]
    end
   response
  end

  def id
    'rmapi'
  end

  def valid?(arg = {})
    urlstr = "#{ENV['EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL']}/rm/rmaccounts/#{@customer_id}/vendors?search=zz12&offset=1&orderby=vendorname&count=1"

    open(urlstr,{'X-Api-Key' => @api_key})

  rescue Exception => e
    @errors = [e.message]
    false
  end

  def save(options = {})
    response = @okapi.user.get '/configurations/entries?query=module=KB_EBSCO'

    response["configs"].each do |config|
      id = config["id"]
      @okapi.user.delete "/configurations/entries/#{id}"
    end

    @okapi.user.post('/configurations/entries',  { "module": "KB_EBSCO", "configName": "api_credentials", "code": "kb.ebsco.credentials", "description": "EBSCO RM-API Credentials", "enabled": true, "value": "customer-id=#{customer_id}&api-key=#{@api_key}"})

  end
end
