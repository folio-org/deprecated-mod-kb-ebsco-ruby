# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Labels', type: :request do
  describe 'getting custom labels' do
    before do
      VCR.use_cassette('get-custom-labels-success') do
        get '/eholdings/custom-labels',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:attributes) { json.data.first.attributes }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it "is of type 'customLabel'" do
      expect(json.data.first.type).to eq('customLabel')
    end
    it 'has 5 custom labels' do
      expect(json.data.length).to eq(5)
    end

    describe 'check each custom label attributes' do
      it 'has id key' do
        expect(attributes).to have_key(:id)
      end
      it 'has display label key' do
        expect(attributes).to have_key(:displayLabel)
      end
      it 'has display on full text finder key' do
        expect(attributes).to have_key(:displayOnFullTextFinder)
      end
      it 'has display on publication finder key' do
        expect(attributes).to have_key(:displayOnPublicationFinder)
      end
    end
  end

  describe 'updating a custom label' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'update the third custom label among five' do
      let(:params) do
        {
          'data' => {
            'id' => '3',
            'type' => 'customLabel',
            'attributes' => {
              'id' => 3,
              'displayLabel' => 'Hello third label',
              'displayOnFullTextFinder' => true,
              'displayOnPublicationFinder' => true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-update-third') do
          put '/eholdings/custom-labels/3',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'gets a successful response' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      describe 'check attributes of updated custom label' do
        it 'has id of 3' do
          expect(attributes.id).to eq(3)
        end
        it 'has display label key that matches the recent update' do
          expect(attributes.displayLabel).to eq('Hello third label')
        end
        it 'has display on full text finder key' do
          expect(attributes.displayOnFullTextFinder).to eq(true)
        end
        it 'has display on publication finder key' do
          expect(attributes.displayOnPublicationFinder).to eq(true)
        end
      end
    end

    describe 'update an invalid custom label' do
      let(:params) do
        {
          'data' => {
            'id' => 'customLabel',
            'type' => 'customLabel',
            'attributes' => {
              'id' => 7,
              'displayLabel' => 'Hello seventh label',
              'displayOnFullTextFinder' => true,
              'displayOnPublicationFinder' => true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-update-seventh') do
          put '/eholdings/custom-labels/7',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update a custom label with non-matching ids' do
      let(:params) do
        {
          'data' => {
            'id' => 'customLabel',
            'type' => 'customLabel',
            'attributes' => {
              'id' => 7,
              'displayLabel' => 'Hello seventh label',
              'displayOnFullTextFinder' => true,
              'displayOnPublicationFinder' => true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-non-matching') do
          put '/eholdings/custom-labels/2',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update a custom label where path param id is invalid' do
      let(:params) do
        {
          'data' => {
            'id' => 'customLabel',
            'type' => 'customLabel',
            'attributes' => {
              'id' => 'blob',
              'displayLabel' => 'Hello blob label',
              'displayOnFullTextFinder' => true,
              'displayOnPublicationFinder' => true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-update-blob') do
          put '/eholdings/custom-labels/2',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update a custom label without all parameters' do
      let(:params) do
        {
          'data' => {
            'id' => 'customLabel',
            'type' => 'customLabel',
            'attributes' => {
              'id' => 'blob',
              'displayLabel' => 'Hello blob label',
              'displayOnPublicationFinder' => true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-without-all-parameters') do
          put '/eholdings/custom-labels/2',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update a custom label with empty display label' do
      let(:params) do
        {
          'data' => {
            'id' => 'customLabel',
            'type' => 'customLabel',
            'attributes' => {
              'id' => 3,
              'displayLabel' => '',
              'displayOnPublicationFinder' => true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-with-empty-display-label') do
          put '/eholdings/custom-labels/3',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'update a custom label without a body' do
      let(:params) do
        {
          'data' => {
            'id' => 'customLabel',
            'type' => 'customLabel',
            'attributes' => {
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-label-with-empty-body') do
          put '/eholdings/custom-labels/3',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'results in error' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'deleting a custom label that exists and is valid' do
    before do
      VCR.use_cassette('delete-custom-labels-success') do
        delete '/eholdings/custom-labels/1',
               headers: okapi_headers
      end
    end

    it 'gets a successful response' do
      expect(response).to have_http_status(204)
    end
  end

  describe 'deleting a custom label that is already deleted' do
    before do
      VCR.use_cassette('delete-custom-labels-bad-request') do
        delete '/eholdings/custom-labels/1',
               headers: okapi_headers
      end
    end

    it 'gets a resource not found status as response' do
      expect(response).to have_http_status(404)
    end
  end

  describe 'deleting a custom label that is invalid' do
    before do
      VCR.use_cassette('delete-custom-labels-unprocessable-request') do
        delete '/eholdings/custom-labels/10',
               headers: okapi_headers
      end
    end

    it 'gets a resource not found status as response' do
      expect(response).to have_http_status(404)
    end
  end
end
