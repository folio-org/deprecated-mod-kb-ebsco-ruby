# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Providers', type: :request do
  describe 'searching for providers' do
    before do
      VCR.use_cassette('search-providers') do
        get '/eholdings/providers/?q=e', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets a list of resources' do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(101)
      expect(json.data.first.type).to eq('providers')
    end

    it 'contains relationships data' do
      expect(json.data.first.relationships). to include('packages')
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('search-providers-page2') do
          get '/eholdings/providers/?q=e&page=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(101)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
        expect(json.data.first.type).to eq('providers')
      end

      it 'contains relationships data' do
        expect(json2.data.first.relationships). to include('packages')
      end
    end

    describe 'with alphabetical sorting' do
      before do
        VCR.use_cassette('search-providers-sort-name') do
          get '/eholdings/providers/?q=higher%20education&sort=name',
              headers: okapi_headers
        end
      end

      let!(:json_n) { Map JSON.parse response.body }

      it 'contains a list of alphabetically A-Z sorted resources' do
        expect(response).to have_http_status(200)
        expect(json_n.data.length).to equal(20)
        expect(json_n.meta.totalResults).to equal(20)
        expect(json_n.data.first.type).to eq('providers')
        sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
        expect(json_n.data).to eq(sorted_array)
      end
    end

    describe 'with relevance sorting' do
      before do
        VCR.use_cassette('search-providers-sort-relevance') do
          get '/eholdings/providers/?q=higher%20education&sort=relevance',
              headers: okapi_headers
        end
      end

      let!(:json_n) { Map JSON.parse response.body }

      it 'contains a list of relevancy sorted resources' do
        expect(response).to have_http_status(200)
        expect(json_n.data.length).to equal(20)
        expect(json_n.meta.totalResults).to equal(20)
        expect(json_n.data.first.type).to eq('providers')
        expect(json_n.data[0].attributes.name.downcase).to include(
          'higher education'
        )
        sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
        expect(json_n.data).not_to eq(sorted_array)
      end
    end

    describe 'with default sorting' do
      before do
        VCR.use_cassette('search-providers-sort-default') do
          get '/eholdings/providers/?q=higher%20education',
              headers: okapi_headers
        end
      end

      let!(:json_n) { Map JSON.parse response.body }

      it 'contains a list of relevancy sorted resources' do
        expect(response).to have_http_status(200)
        expect(json_n.data.length).to equal(20)
        expect(json_n.meta.totalResults).to equal(20)
        expect(json_n.data.first.type).to eq('providers')
        expect(json_n.data[0].attributes.name.downcase).to include(
          'higher education'
        )
        sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
        expect(json_n.data).not_to eq(sorted_array)
      end
    end

    describe 'with sorting and no query' do
      before do
        VCR.use_cassette('search-providers-sort-noquery') do
          get '/eholdings/providers/',
              headers: okapi_headers
        end
      end

      let!(:json_n) { Map JSON.parse response.body }

      it 'contains a list of alphabetically sorted resources' do
        expect(response).to have_http_status(200)
        expect(json_n.data.length).to equal(25)
        expect(json_n.meta.totalResults).to equal(1716)
        expect(json_n.data.first.type).to eq('providers')
        sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
        expect(json_n.data).to eq(sorted_array)
      end
    end
  end

  describe 'getting a specific provider' do
    before do
      VCR.use_cassette('get-providers-success') do
        get '/eholdings/providers/19', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('providers')
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

  describe 'getting a provider with included packages' do
    before do
      VCR.use_cassette('get-providers-include-packages-success') do
        get '/eholdings/providers/19?include=packages', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets associated package records' do
      expect(response).to have_http_status(200)
      expect(json.included.first.type).to eq('packages')
      expect(json.included.length).to eq(25)
      expect(json.data.relationships.packages.data.length).to eq(25)
      expect(json.included.first.attributes).to(
        include(
          'vendorId',
          'vendorName',
          'providerId',
          'providerName'
        )
      )
    end

    it 'contains relationships data' do
      expect(json.included.first.relationships). to(
        include(
          'customerResources',
          'vendor',
          'provider'
        )
      )
    end
  end

  describe 'getting packages related to provider' do
    before do
      VCR.use_cassette('get-providers-related-packages-success') do
        get '/eholdings/providers/19/packages', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets associated package records' do
      expect(response).to have_http_status(200)
      expect(json.data.first.type).to eq('packages')
      expect(json.data.length).to eq(25)
      expect(json.meta.totalResults).to equal(628)
      expect(json.data.first.attributes).to(
        include(
          'vendorId',
          'vendorName',
          'providerId',
          'providerName'
        )
      )
    end

    it 'contains relationships data' do
      expect(json.data.first.relationships). to(
        include(
          'customerResources',
          'vendor',
          'provider'
        )
      )
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('get-providers-related-packages-success-page2') do
          get '/eholdings/providers/19/packages?page=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(628)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end

      it 'contains relationships data' do
        expect(json.data.first.relationships). to(
          include(
            'customerResources',
            'vendor',
            'provider'
          )
        )
      end
    end
  end

  describe 'getting a non-existing provider' do
    before do
      VCR.use_cassette('get-provider-not-found') do
        get '/eholdings/providers/1', headers: okapi_headers
      end
    end

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
    end
  end
end
