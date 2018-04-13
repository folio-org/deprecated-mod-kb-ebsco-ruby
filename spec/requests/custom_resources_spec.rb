# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Resources', type: :request do
  describe 'editing a custom title' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'changing the name and publication type' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "name": 'I have a great new title name'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-name') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has the new name' do
        expect(json.data.attributes.name).to eq('I have a great new title name')
      end
    end

    describe 'changing the publication type' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "publicationType": 'Book Series'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-pubtype') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has the new publication type' do
        expect(json.data.attributes.publicationType).to eq('Book Series')
      end
    end

    describe 'changing the coverage dates' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              'customCoverages': [
                {
                  'beginCoverage': '2003-01-01',
                  'endCoverage': '2004-01-01'
                }
              ],
              "isSelected": true
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-coverage-dates') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'now has custom coverage' do
        expect(json.data.attributes.customCoverages[0].beginCoverage)
          .to eq('2003-01-01')
        expect(json.data.attributes.customCoverages[0].endCoverage)
          .to eq('2004-01-01')
      end
    end

    describe 'changing the visibility' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "visibilityData": {
                "isHidden": true,
                "reason": ''
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-visibility') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'is now hidden' do
        expect(json.data.attributes.visibilityData.isHidden).to be true
      end
    end

    describe 'changing the embargo period' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "customEmbargoPeriod": {
                "embargoUnit": 'Weeks',
                "embargoValue": 6
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-embargo-period') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has a custom embargo period' do
        expect(json.data.attributes.customEmbargoPeriod.embargoUnit)
          .to eq('Weeks')
        expect(json.data.attributes.customEmbargoPeriod.embargoValue)
          .to eq(6)
      end
    end

    describe 'changing the embargo period' do
      let(:params) do
        {
          "data": {
            "type": 'resources',
            "attributes": {
              "isSelected": true,
              "coverageStatement": 'We have so much coverage.'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-resource-coverage-statement') do
          put '/eholdings/resources/123355-2845510-62477',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has a coverage statement' do
        expect(json.data.attributes.coverageStatement)
          .to eq('We have so much coverage.')
      end
    end
  end
end
