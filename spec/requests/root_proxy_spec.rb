# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root Proxies', type: :request do
  describe 'getting list of root proxies' do
    before do
      VCR.use_cassette('get-root-proxies-success') do
        get '/eholdings/root-proxies',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:attributes) { json.data.first.attributes }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it "is of type 'rootProxy'" do
      expect(json.data.first.type).to eq('rootProxy')
    end

    describe 'check each root proxy attributes' do
      it 'has id key' do
        expect(attributes).to have_key(:id)
      end
      it 'has name key' do
        expect(attributes).to have_key(:name)
      end
      it 'has url mask key' do
        expect(attributes).to have_key(:urlMask)
      end
      it 'has selected key' do
        expect(attributes).to have_key(:selected)
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
          'data' => {
            'id' => 'EZProxy',
            'type' => 'rootProxy',
            'attributes' => {
              'id' => 'EZProxy'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-success') do
          put '/eholdings/root-proxies/EZProxy',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'gets a successful response' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      describe 'check attributes of new root proxy' do
        it 'has id of EZProxy' do
          expect(attributes.id).to eq('EZProxy')
        end
        it 'has name equals nil because its not updated' do
          expect(attributes.name).to be_nil
        end
        it 'has urlmask equals nil because its not updated' do
          expect(attributes.urlMask).to be_nil
        end
        it 'has selection set to true' do
          expect(attributes.selected).to eq(true)
        end
      end
    end

    describe 'update a root proxy with non-matching ids' do
      let(:params) do
        {
          'data' => {
            'id' => 'EZProxy',
            'type' => 'rootProxy',
            'attributes' => {
              'id' => 'EZProxy'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-non-matching') do
          put '/eholdings/root-proxies/some_value',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update root proxy with invalid value' do
      let(:params) do
        {
          'data' => {
            'id' => 'test-123',
            'type' => 'rootProxy',
            'attributes' => {
              'id' => 'test-123'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-invalid') do
          put '/eholdings/root-proxies/test-123',
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
          'data' => {
            'id' => 'EZProxy',
            'type' => 'rootProxy',
            'attributes' => {
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-root-proxy-with-empty-body') do
          put '/eholdings/root-proxies/EZProxy',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end
  end
end
