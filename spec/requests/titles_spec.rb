# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Titles', type: :request do
  describe 'searching for titles' do
    before do
      VCR.use_cassette('search-titles') do
        get '/eholdings/titles/?q=ebsco', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets a list of resources' do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(61)
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('search-titles-page2') do
          get '/eholdings/titles/?q=ebsco&page=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(61)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end
    end

    describe 'filtering by publication type' do
      before do
        VCR.use_cassette('search-titles-filter-book') do
          filter = { filter: { type: 'book' } }.to_query
          get "/eholdings/titles/?q=news&#{filter}", headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'gets a list of book resources' do
        expect(response).to have_http_status(200)
        expect(json_f.data.length).to equal(25)
        expect(json_f.meta.totalResults).to equal(1296)
        expect(json_f.data.first.attributes.publicationType).to eql('Book')
      end

      describe 'filtering further by selected status' do
        before do
          VCR.use_cassette('search-titles-filter-book-selection') do
            filter = { filter: { type: 'book', selected: true } }.to_query
            get "/eholdings/titles/?q=news&#{filter}", headers: okapi_headers
          end
        end

        let!(:json_f2) { Map JSON.parse response.body }

        it 'gets a list of unselected book resources' do
          expect(response).to have_http_status(200)
          expect(json_f2.data.length).to equal(25)
          expect(json_f2.meta.totalResults).to equal(1278)
          expect(json_f2.data.first.attributes.publicationType).to eql('Book')
          expect(json_f2.data.first.id).not_to eql(json_f.data.first.id)
        end
      end
    end

    describe 'with an invalid filter param' do
      before do
        VCR.use_cassette('search-titles-filter-invalid') do
          get '/eholdings/titles/?q=news&filter=invalid', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'gets a list of unselected book resources' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid filter parameter')
      end
    end
  end

  describe 'getting a specific title' do
    before do
      VCR.use_cassette('get-titles-success') do
        get '/eholdings/titles/316875', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('titles')
      expect(json.data.id).to eq('316875')
      expect(json.data.attributes).to include(
        'name',
        'description',
        'publisherName',
        'publicationType',
        'isTitleCustom',
        'isPeerReviewed',
        'contributors',
        'identifiers',
        'subjects'
      )
      expect(json.data.relationships).to include('customerResources')
    end

    it 'returns identifiers as human readable types and subtypes' do
      expect(json.data.attributes.identifiers).to include(
        'id' => '316875',
        'type' => 'BHM',
        'subtype' => 'Empty'
      )
    end

    it 'returns a human readable publication type' do
      expect(json.data.attributes.publicationType).to eq('Book')
    end
  end

  describe 'getting a title with included customer resources' do
    before do
      VCR.use_cassette('get-titles-customer-resources') do
        get '/eholdings/titles/316875?include=customerResources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a list of customers resources' do
      expect(json.data.relationships.customerResources.data.length).to eq(24)
      expect(json.included.length).to eq(24)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('customerResources')
    end
  end

  describe 'getting customer resources related to title' do
    before do
      VCR.use_cassette('get-titles-related-customer-resources') do
        get '/eholdings/titles/316875/customer-resources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'responds with a list of customers resources' do
      expect(json.data.length).to eq(24)
    end

    it 'returns the correct included type' do
      expect(json.data.first.type).to eq('customerResources')
    end
  end

  describe 'getting a title with empty array fields' do
    before do
      VCR.use_cassette('get-titles-empty-array-fields') do
        get '/eholdings/titles/146131', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'returns empty arrays for array attributes' do
      expect(json.data.attributes.contributors).to eq([])
      expect(json.data.attributes.subjects).to eq([])
    end
  end

  describe 'getting a non-existing title' do
    before do
      VCR.use_cassette('get-titles-not-found') do
        get '/eholdings/titles/1', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
      expect(json.errors).to include(title: 'Title not found')
    end
  end
end
