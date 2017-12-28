# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Vendors', type: :request do
  describe 'searching for vendors' do
    before do
      VCR.use_cassette('search-vendors') do
        get '/eholdings/vendors/?q=e', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets a list of resources' do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(101)
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('search-vendors-page2') do
          get '/eholdings/vendors/?q=e&page=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(101)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end
    end
  end

  describe 'getting a specific vendor' do
    before do
      VCR.use_cassette('get-vendors-success') do
        get '/eholdings/vendors/19', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('vendors')
      expect(json.data.id).to eq('19')
      expect(json.data.attributes).to(
        include(
          'name',
          'packagesTotal',
          'packagesSelected'
        )
      )
    end

    it 'contains relationships data' do
      expect(json.data.relationships). to include('packages')
    end
  end

  describe 'getting a vendor with included packages' do
    before do
      VCR.use_cassette('get-vendors-include-packages-success') do
        get '/eholdings/vendors/19?include=packages', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets associated package records' do
      expect(response).to have_http_status(200)
      expect(json.included.first.type).to eq('packages')
      expect(json.included.length).to eq(25)
      expect(json.data.relationships.packages.data.length).to eq(25)
    end
  end

  describe 'getting packages related to vendor' do
    before do
      VCR.use_cassette('get-vendors-related-packages-success') do
        get '/eholdings/vendors/19/packages', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets associated package records' do
      expect(response).to have_http_status(200)
      expect(json.data.first.type).to eq('packages')
      expect(json.data.length).to eq(25)
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('get-vendors-related-packages-page2') do
          get '/eholdings/vendors/19/packages?page=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(101)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end
    end
  end

  describe 'getting a non-existing vendor' do
    before do
      VCR.use_cassette('get-vendors-not-found') do
        get '/eholdings/vendors/1', headers: okapi_headers
      end
    end

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
    end
  end
end
