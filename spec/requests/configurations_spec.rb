require 'rails_helper'

RSpec.describe "Configurations", type: :request do

  let(:customer_id) { ENV['TEST_CUSTOMER_ID'] }
  let(:api_key) { ENV['TEST_API_KEY'] }
  let(:okapi_token) { ENV['TEST_OKAPI_TOKEN'] }
  let(:resource) do
    ['/eholdings/configuration', params: {data:{ type: "configurations", id: 'default', attributes: {"customer-id": customer_id, "api-key": api_key} }}.to_json, headers: {'Content-Type': 'application/vnd.api+json','X-Okapi-Url': 'https://okapi-sandbox.frontside.io', 'X-Okapi-Tenant': 'fs', 'X-Okapi-Token': okapi_token}]
  end

  describe "setting the configuration when it has never been set before" do
    before do
      VCR.use_cassette("put-configuration") do
        put(*resource)
      end
    end

    let!(:json) {Map JSON.parse response.body}

    it 'expects the response to have 200' do
      expect(response).to have_http_status(200)
    end

    describe "reading the configuration" do
      before do
        VCR.use_cassette("get-configuration") do
          get(*resource)
        end
      end

      it 'expect the response to be 200' do
        expect(response).to have_http_status(200)
      end

      it 'contains valid attributes' do
        expect(json.data.attributes['customer-id']).to eql(customer_id)
        expect(json.data.attributes['api-key']).to eql(api_key)
      end
    end
  end

  describe "trying to fetch configuration without a url" do
    before do
      get '/eholdings/configuration'
    end

    it 'returns a bad request code' do
      expect(response).to have_http_status(400)
    end
  end

  describe "trying to fetch configuration without a tenant" do
    before do
      get '/eholdings/configuration', params:{}, headers: {'X-Okapi-Url': 'https://frontside.io' }
    end

    it 'returns a bad request code' do
      expect(response).to have_http_status(400)
    end
  end

  describe "trying to fetch configuration without a token" do
    before do
      get '/eholdings/configuration', params:{}, headers: {'X-Okapi-Url': 'https://frontside.io', 'X-Okapi-Tenant': 'fs' }
    end

    it 'returns a bad request code' do
      expect(response).to have_http_status(400)
    end
  end

end
