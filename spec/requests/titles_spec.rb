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
      expect(json.meta.totalResults).to equal(59)
      expect(json.data.first.attributes).to_not include(
        'description',
        'edition',
        'isPeerReviewed',
        'contributors'
      )
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
        expect(json2.meta.totalResults).to equal(59)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end
    end

    describe 'with count within range' do
      before do
        VCR.use_cassette('search-titles-specify-count') do
          get '/eholdings/titles/?q=ebsco&count=5', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets five results of titles' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(5)
        expect(json2.meta.totalResults).to equal(59)
      end
    end

    describe 'with count out of range' do
      before do
        VCR.use_cassette('search-titles-specify-count-out-of-range') do
          get '/eholdings/titles/?q=e&count=150', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gives expected error response' do
        expect(response).to have_http_status(400)
        expect(json2.errors.first.title).to eq('Parameter \'count\' is outside the range 1-100.')
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
        expect(json_f.meta.totalResults).to equal(3949)
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
          expect(json_f2.meta.totalResults).to equal(1474)
          expect(json_f2.data.first.attributes.publicationType).to eql('Book')
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

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid selectedFilter')
      end
    end

    describe 'with an invalid query param filter[selected]' do
      before do
        VCR.use_cassette('search-titles-invalid-query-param-selected') do
          get '/eholdings/titles/?q=ebsco&filter[selected]=doNotEnter', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid selectedFilter')
      end
    end

    describe 'with an invalid query param filter[type]' do
      before do
        VCR.use_cassette('search-titles-invalid-query-param-type') do
          get '/eholdings/titles/?q=ebsco&filter[type]=doNotEnter', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid contentTypeFilter')
      end
    end

    describe 'with an invalid query param searchField' do
      before do
        VCR.use_cassette('search-titles-invalid-query-param-search-field') do
          get '/eholdings/titles/?q=ebsco&searchfield=doNotEnter', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid searchField')
      end
    end

    describe 'with search field titlename filter' do
      before do
        VCR.use_cassette('search-titles-filter-titlename') do
          get '/eholdings/titles/?filter[name]=ebsco', headers: okapi_headers
        end
      end

      let!(:json_t) { Map JSON.parse response.body }

      it 'gets a filtered list of resources' do
        expect(response).to have_http_status(200)
        expect(json_t.data.length).to equal(25)
        expect(json_t.meta.totalResults).to equal(59)
        json_t.data.each do |title|
          expect(title.attributes.name.downcase).to include('ebsco')
        end
      end

      describe 'with titlename filter and pagination' do
        before do
          VCR.use_cassette('search-titles-filter-titlename-page2') do
            get '/eholdings/titles/?filter[name]=ebsco&page=2',
                headers: okapi_headers
          end
        end

        let!(:json_t2) { Map JSON.parse response.body }

        it 'gets a different list of resources' do
          expect(response).to have_http_status(200)
          expect(json_t2.data.length).to equal(25)
          expect(json_t2.meta.totalResults).to equal(59)
          expect(json_t2.data.first.id).not_to eql(json_t.data.first.id)
        end
      end
    end

    describe 'with search field isxn filter' do
      before do
        VCR.use_cassette('search-titles-filter-isxn') do
          get '/eholdings/titles/?filter[isxn]=1362-3613',
              headers: okapi_headers
        end
      end

      let!(:json_i) { Map JSON.parse response.body }

      it 'gets a filtered list of resources' do
        expect(response).to have_http_status(200)
        expect(json_i.data.length).to equal(1)
        expect(json_i.meta.totalResults).to equal(1)
        expect(json_i.data.first.attributes.identifiers).to include(
          'id' => '1362-3613',
          'type' => 'ISSN',
          'subtype' => 'Print'
        )
      end
    end

    describe 'with search field subject filter' do
      before do
        VCR.use_cassette('search-titles-filter-subject') do
          get '/eholdings/titles/?filter[subject]=history',
              headers: okapi_headers
        end
      end

      let!(:json_h) { Map JSON.parse response.body }

      it 'gets a filtered list of resources' do
        expect(response).to have_http_status(200)
        expect(json_h.data.length).to equal(25)
        expect(json_h.meta.totalResults).to equal(194_042)
        json_h.data.each do |title|
          expect(title.attributes.subjects.any? do |sub|
            sub.name.downcase.include?('history')
          end).to be true
        end
      end
    end

    describe 'with conflicting search field filters' do
      before do
        VCR.use_cassette('search-titles-filter-conflict') do
          get '/eholdings/titles/?filter[subject]=history&filter[name]=ebsco',
              headers: okapi_headers
        end
      end

      let!(:json_c) { Map JSON.parse response.body }

      it 'returns a bad request' do
        expect(response).to have_http_status(400)
        expect(json_c.errors.first.title).to eql(
          'Conflicting filter parameters'
        )
      end
    end

    describe 'with conflicting query parameters' do
      before do
        VCR.use_cassette('search-titles-query-conflict') do
          get '/eholdings/titles/?q=ebsco&filter[name]=ebsco',
              headers: okapi_headers
        end
      end

      let!(:json_c) { Map JSON.parse response.body }

      it 'returns a bad request' do
        expect(response).to have_http_status(400)
        expect(json_c.errors.first.title).to eql(
          'Conflicting query parameters'
        )
      end
    end
  end

  # NOTE: alphabetical sorting tests for titles are currently limited
  # due to a limitation in RM API. Cannot compare sorted results with
  # a sorted list (some titles appear out of order).
  # Additionally the same search with different sorts yields different counts.
  # Title sorting is not being invoked from UI until
  # sort limitation and a title count difference is resolved.
  describe 'with alphabetical sorting' do
    before do
      VCR.use_cassette('search-titles-sort-name') do
        get '/eholdings/titles/?filter[name]=victorian%20fashion&sort=name',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of alphabetically A-Z sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(4444)
      expect(json_n.data.first.type).to eq('titles')
      expect(json_n.data[0].attributes.name.downcase).not_to include(
        'victorian fashion'
      )
    end
  end

  describe 'with relevance sorting' do
    before do
      VCR.use_cassette('search-titles-sort-relevance') do
        get '/eholdings/titles/?filter[name]=victorian%20fashion&sort=relevance',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of relevancy sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(4444)
      expect(json_n.data.first.type).to eq('titles')
      expect(json_n.data[0].attributes.name.downcase).to include(
        'victorian fashion'
      )
      sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
      expect(json_n.data).not_to eq(sorted_array)
    end
  end

  describe 'with default sorting' do
    before do
      VCR.use_cassette('search-titles-sort-default') do
        get '/eholdings/titles/?filter[name]=victorian%20fashion',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of relevancy sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(4444)
      expect(json_n.data.first.type).to eq('titles')
      expect(json_n.data[0].attributes.name.downcase).to include(
        'victorian fashion'
      )
      sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
      expect(json_n.data).not_to eq(sorted_array)
    end
  end

  describe 'identifiers are sorted by subtype' do
    before do
      VCR.use_cassette('search-titles-sort-identifiers') do
        get '/eholdings/titles/?page=1&filter[name]=a',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains identifiers that are sorted by subtype and type' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.data[6].id).to eq('3119726')
      expect(json_n.data[6].attributes.identifiers.length).to eq(2)
      expect(json_n.data[6].attributes.identifiers[0].subtype).to eq('Empty')
      expect(json_n.data[6].attributes.identifiers[1].subtype).to eq('Online')
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
        'subjects',
        'edition'
      )
      expect(json.data.relationships).to include('resources')
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

  describe 'getting a title with included resources' do
    before do
      VCR.use_cassette('get-titles-resources') do
        get '/eholdings/titles/316875?include=resources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a list of resources' do
      expect(json.data.relationships.resources.data.length).to eq(24)
      expect(json.included.length).to eq(24)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('resources')
    end
  end

  describe 'getting a specific title with identifiers sorted by subtype and type' do
    before do
      VCR.use_cassette('get-titles-sorted-identifiers') do
        get '/eholdings/titles/169441',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'contains identifiers that are sorted by subtype and type' do
      expect(response).to have_http_status(200)
      expect(json.data.id).to eq('169441')
      expect(json.data.attributes.identifiers.length).to eq(4)
      expect(json.data.attributes.identifiers[0].subtype).to eq('Empty')
      expect(json.data.attributes.identifiers[1].subtype).to eq('Print')
      expect(json.data.attributes.identifiers[2].subtype).to eq('Online')
      expect(json.data.attributes.identifiers[0].type).to eq('BHM')
      expect(json.data.attributes.identifiers[1].type).to eq('ISBN')
    end
  end

  describe 'getting resources related to title' do
    before do
      VCR.use_cassette('get-titles-related-resources') do
        get '/eholdings/titles/316875/resources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'responds with a list of resources' do
      expect(json.data.length).to eq(24)
    end

    it 'returns the correct included type' do
      expect(json.data.first.type).to eq('resources')
    end
  end

  describe 'getting a custom title with empty array fields' do
    before do
      VCR.use_cassette('get-custom-title') do
        get '/eholdings/titles/17059784', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'returns empty arrays for array attributes' do
      expect(json.data.attributes.identifiers).to eq([])
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

  describe 'getting a custom title with edition in it' do
    before do
      VCR.use_cassette('get-titles-edition-success') do
        get '/eholdings/titles/17059786', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('titles')
      expect(json.data.id).to eq('17059786')
      expect(json.data.attributes).to include(
        'name',
        'edition',
        'description',
        'publisherName',
        'publicationType',
        'isTitleCustom',
        'isPeerReviewed',
        'contributors',
        'identifiers',
        'subjects'
      )
      expect(json.data.attributes.edition).to eq('some edition')
    end
  end
end
