require 'rails_helper'

RSpec.describe "Configurations", type: :request do

  let(:customer_id) { ENV.fetch('TEST_CUSTOMER_ID') }
  let(:api_key) { ENV.fetch('TEST_API_KEY') }
  let(:okapi_token) { ENV.fetch('TEST_OKAPI_TOKEN') }

  let(:headers) {
    {
      'Content-Type': 'application/vnd.api+json',
      'X-Okapi-Url': 'https://okapi-sandbox.frontside.io',
      'X-Okapi-Tenant': 'fs',
      'X-Okapi-Token': okapi_token
    }
  }

  let(:resource) do
    [
      '/eholdings/configuration',
      params: {
        data: {
          type: "configurations",
          id: 'default',
          attributes: {
            customerId: customer_id,
            apiKey: api_key
          }
        }
      }.to_json,
      headers: headers
    ]
  end

  describe "setting the configuration when it has never been set before" do
    before do
      VCR.use_cassette("put-configuration") do
        put(*resource)
      end
    end

    let!(:json) { Map JSON.parse response.body }

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
        expect(json.data.attributes.customerId).to eql(customer_id)
        expect(json.data.attributes.apiKey).to eql(api_key)
      end
    end
  end

  describe "setting the configuration with invalid JSON" do
    before do
      VCR.use_cassette("put-configuration-bad") do
        put(
          '/eholdings/configuration',
          params: {
            customerId: customer_id,
            apiKey: api_key
          }.to_json,
          headers: headers
        )
      end
    end

    it "returns an unprocessable entity code" do
      expect(response).to have_http_status(422)
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
