# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Configurations', type: :request do
  let(:headers) do
    okapi_headers.merge(
      'Content-Type': 'application/vnd.api+json'
    )
  end

  let(:resource) do
    [
      '/eholdings/configuration',
      params: {
        data: {
          type: 'configurations',
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

  let(:masked_api_key) do
    '*' * 40
  end

  describe 'setting the configuration when it has never been set before' do
    before do
      VCR.use_cassette('put-configuration') do
        put(*resource)
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'expects the response to have 200' do
      expect(response).to have_http_status(200)
    end

    describe 'reading the configuration' do
      before do
        VCR.use_cassette('get-configuration') do
          get(*resource)
        end
      end

      it 'expect the response to be 200' do
        expect(response).to have_http_status(200)
      end

      it 'contains valid attributes' do
        expect(json.data.attributes.customerId).to eql(customer_id)
        expect(json.data.attributes.apiKey).to eql(masked_api_key)
      end
    end
  end

  describe 'setting the configuration with invalid JSON' do
    before do
      VCR.use_cassette('put-configuration-bad') do
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

    it 'returns an unprocessable entity code' do
      expect(response).to have_http_status(422)
    end
  end

  describe 'trying to fetch configuration without a url' do
    before do
      get '/eholdings/configuration'
    end

    it 'returns a bad request code' do
      expect(response).to have_http_status(400)
    end
  end

  describe 'trying to fetch configuration without a tenant' do
    before do
      get '/eholdings/configuration',
          headers: {
            'X-Okapi-Url': 'https://frontside.io'
          },
          params: {}
    end

    it 'returns a bad request code' do
      expect(response).to have_http_status(400)
    end
  end

  describe 'trying to fetch configuration without a token' do
    before do
      get '/eholdings/configuration',
          headers: {
            'X-Okapi-Url': 'https://frontside.io',
            'X-Okapi-Tenant': 'fs'
          },
          params: {}
    end

    it 'returns a bad request code' do
      expect(response).to have_http_status(400)
    end
  end
end
