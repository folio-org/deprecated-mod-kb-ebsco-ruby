# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root Proxies', type: :request do
  describe 'getting list of root proxies' do
    before do
      VCR.use_cassette('get-root-proxies-success') do
        get '/eholdings/proxy-types',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:attributes) { json.data.first.attributes }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it "is of type 'proxyType'" do
      expect(json.data.first.type).to eq('proxyTypes')
    end

    describe 'check attributes of proxyType' do
      it 'has id key' do
        expect(attributes).to have_key(:id)
      end
      it 'has name key' do
        expect(attributes).to have_key(:name)
      end
      it 'has url mask key' do
        expect(attributes).to have_key(:urlMask)
      end
    end
  end

  describe 'updating selection of root proxy' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'select a different root proxy' do
      let(:params) do
        {
          "data": {
            "type": 'rootProxies',
            "id": 'EZProxy',
            "attributes": {
              "id": 'eholdings/root-proxy',
              "proxyTypeId": 'EZProxy'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-success') do
          put '/eholdings/root-proxy',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'gets a successful response' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      describe 'check attributes of new root proxy' do
        it 'has id of eholdings/root-proxy' do
          expect(attributes.id).to eq('eholdings/root-proxy')
        end
        it 'has id of EZProxy' do
          expect(attributes.proxyTypeId).to eq('EZProxy')
        end
      end
    end

    describe 'update a root proxy with non-matching ids' do
      let(:params) do
        {
          "data": {
            "id": 'eholdings/root-proxy',
            "type": 'rootProxies',
            "attributes": {
              "id": 'eholdings/root-proxy',
              "proxyTypeId": 'EZProxyPOPS'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-non-matching') do
          put '/eholdings/root-proxy',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'fails Validation' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update root proxy with invalid value' do
      let(:params) do
        {
          "data": {
            "id": 'eholdings/root-proxy',
            "type": 'rootProxies',
            "attributes": {
              "id": 'eholdings/root-proxy'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-invalid') do
          put '/eholdings/root-proxy',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update a root proxy without a body' do
      let(:params) do
        {
          "data": {
            "type": 'rootProxies',
            "id": 'EZProxy',
            "attributes": {
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-with-empty-body') do
          put '/eholdings/root-proxy',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end
  end
end
