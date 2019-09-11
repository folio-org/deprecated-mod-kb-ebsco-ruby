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
      expect(json.meta.totalResults).to equal(115)
      expect(json.data.first.type).to eq('providers')
      expect(json.data.first.attributes).to_not include('proxy')
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
        expect(json2.meta.totalResults).to equal(115)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
        expect(json.data.first.type).to eq('providers')
      end

      it 'contains relationships data' do
        expect(json2.data.first.relationships). to include('packages')
      end
    end

    describe 'with count within range' do
      before do
        VCR.use_cassette('search-providers-specify-count') do
          get '/eholdings/providers/?q=e&count=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets two providers results' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(2)
        expect(json.data.first.type).to eq('providers')
        expect(json2.meta.totalResults).to equal(115)
      end

      it 'contains relationships data' do
        expect(json2.data.first.relationships). to include('packages')
      end
    end

    describe 'with count out of range' do
      before do
        VCR.use_cassette('search-providers-specify-count-out-of-range') do
          get '/eholdings/providers/?q=e&count=200', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gives expected error response' do
        expect(response).to have_http_status(400)
        expect(json2.errors.first.title).to eq('Parameter Count is outside the range 1-100')
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
        expect(json_n.data.length).to equal(25)
        expect(json_n.meta.totalResults).to equal(26)
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
        expect(json_n.data.length).to equal(25)
        expect(json_n.meta.totalResults).to equal(26)
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
        expect(json_n.data.length).to equal(25)
        expect(json_n.meta.totalResults).to equal(26)
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
        expect(json_n.meta.totalResults).to equal(1886)
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
          'packagesSelected',
          'providerToken',
          'supportsCustomPackages',
          'proxy'
        )
      )
    end

    it 'returns null provider token' do
      expect(json.data.attributes.providerToken).to eq(nil)
    end

    it 'returns proxy' do
      expect(json.data.attributes.proxy.id).to eq('EZProxy')
      expect(json.data.attributes.proxy.inherited).to eq(true)
    end

    it 'returns false for supports custom packages' do
      expect(json.data.attributes.supportsCustomPackages).to eq(false)
    end

    it 'contains relationships data' do
      expect(json.data.relationships). to include('packages')
    end
  end

  describe 'getting a provider with a token ' do
    before do
      VCR.use_cassette('get-providers-token') do
        get '/eholdings/providers/18', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('providers')
      expect(json.data.id).to eq('18')
      expect(json.data.attributes).to(
        include(
          'name',
          'packagesTotal',
          'packagesSelected',
          'providerToken',
          'supportsCustomPackages'
        )
      )
    end

    it 'returns provider token attributes' do
      expect(json.data.attributes.providerToken).to include(
        'factName' => '[[galesiteid]]',
        'prompt' => '/itweb/',
        'value' => '99'
      )
    end

    it 'returns provider token help text' do
      expect(json.data.attributes.providerToken).to have_key(:helpText)
    end

    it 'contains relationships data' do
      expect(json.data.relationships). to include('packages')
    end
  end

  describe 'getting a provider that supports custom packages ' do
    before do
      VCR.use_cassette('support-custom-packages') do
        get '/eholdings/providers/123355', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('providers')
      expect(json.data.id).to eq('123355')
      expect(json.data.attributes).to(
        include(
          'name',
          'packagesTotal',
          'packagesSelected',
          'providerToken',
          'supportsCustomPackages'
        )
      )
    end

    it 'supports custom packages' do
      expect(json.data.attributes.supportsCustomPackages).to eq(true)
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
          'resources',
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
      expect(json.meta.totalResults).to equal(624)
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
          'resources',
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
        expect(json2.meta.totalResults).to equal(624)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end

      it 'contains relationships data' do
        expect(json.data.first.relationships). to(
          include(
            'resources',
            'vendor',
            'provider'
          )
        )
      end
    end

    describe 'with a search query' do
      before do
        VCR.use_cassette('search-providers-related-packages') do
          get '/eholdings/providers/19/packages?q=abstract',
              headers: okapi_headers
        end
      end

      let!(:json_with_query) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        json = json_with_query
        name = json.data[0].attributes.name
        expect(response).to have_http_status(200)
        expect(json.data.length).to equal(25)
        expect(json.meta.totalResults).to equal(46)
        expect(name).to eql('Abstracts in Social Gerontology')
      end
    end

    describe 'with a search query and count within range' do
      before do
        VCR.use_cassette('search-providers-related-packages-count-within-range') do
          get '/eholdings/providers/19/packages?q=abstract&count=5',
              headers: okapi_headers
        end
      end

      let!(:json_with_query) { Map JSON.parse response.body }

      it 'gets five packages that matches count' do
        json = json_with_query
        expect(response).to have_http_status(200)
        expect(json.data.length).to equal(5)
        expect(json.meta.totalResults).to equal(46)
      end
    end

    describe 'with a search query and count out of range' do
      before do
        VCR.use_cassette('search-providers-related-packages-count-out-of-range') do
          get '/eholdings/providers/19/packages?q=abstract&count=150',
              headers: okapi_headers
        end
      end

      let!(:json_with_query) { Map JSON.parse response.body }

      it 'gets the expected error message' do
        json = json_with_query
        expect(response).to have_http_status(400)
        expect(json.errors.length).to equal(1)
        expect(json.errors.first.title).to eq('Parameter Count is outside the range 1-100.')
      end
    end

    describe 'with a invalid filter' do
      before do
        VCR.use_cassette(
          'search-providers-related-packages-invalid-filter'
        ) do
          get '/eholdings/providers/19/packages?q=abstract&filter=invalid',
              headers: okapi_headers
        end
      end

      let!(:json_query_invalid_filter) { Map JSON.parse response.body }

      it 'returns a request error' do
        expect(response).to have_http_status(400)
        expect(json_query_invalid_filter.errors.first.title).to eq('Invalid selectedFilter')
        expect(json_query_invalid_filter.errors.first.detail).to eq('Selectedfilter Invalid Query Parameter for filter[selected]')
      end
    end

    describe 'with an invalid query param sort' do
      # VCR not needed here because a request will not be made because the
      # validation will fail and not make the request to RMAPI
      before do
        get '/eholdings/providers/?q=ebsco&sort=doNotEnter', headers: okapi_headers
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid sortFilter')
      end
    end

    describe 'with valid filter options' do
      before do
        VCR.use_cassette('search-providers-related-packages-valid-filter') do
          filter = { filter: { type: 'aggregatedfulltext' } }.to_query
          get '/eholdings/providers/19/packages'\
              "?q=abstract&#{filter}",
              headers: okapi_headers
        end
      end

      let!(:json_query_valid_filter) { Map JSON.parse response.body }

      it 'returns a list limted to filter options passed' do
        expect(response).to have_http_status(200)
        expect(json_query_valid_filter.meta.totalResults).to eql(6)
      end
    end

    describe 'without passing a sort defaults to relevance' do
      before do
        VCR.use_cassette(
          'search-providers-related-packages-no-sort-defaults-relevance'
        ) do
          get '/eholdings/providers/19/packages?q=communication%20abstracts',
              headers: okapi_headers
        end
      end

      let!(:json_query_default_relevance) { Map JSON.parse response.body }

      it 'returns a list sorted by relevance' do
        name = json_query_default_relevance.data[0].attributes.name.downcase
        expect(response).to have_http_status(200)
        expect(name).to eql('communication abstracts (ebsco)')
      end
    end

    describe 'with passing a sort of name' do
      before do
        VCR.use_cassette(
          'search-providers-related-packages-with-name-sort'
        ) do
          get '/eholdings/providers/19/packages'\
              '?q=communication%20abstracts&sort=name',
              headers: okapi_headers
        end
      end

      let!(:json_query_with_name_sort) { Map JSON.parse response.body }

      it 'returns a list sorted by name' do
        expect(response).to have_http_status(200)
        sorted_array = json_query_with_name_sort.data.sort_by do |p|
          p.attributes.name.downcase
        end
        expect(json_query_with_name_sort.data).to eq(sorted_array)
      end
    end

    describe 'with an invalid query param sort within packages query' do
      before do
        VCR.use_cassette(
          'search-providers-related-packages-invalid-sort-query-param'
        ) do
          get '/eholdings/providers/19/packages?q=ebsco&sort=invalid', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid sortFilter')
        expect(json_f.errors.first.detail).to eql('Sortfilter Invalid Query Parameter for sort')
      end
    end

    describe 'with an invalid query param for filter selected within packages query' do
      before do
        VCR.use_cassette(
          'search-providers-related-packages-invalid-filter-selected-query-param'
        ) do
          get '/eholdings/providers/19/packages?q=ebsco&filter[selected]=invalid', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid selectedFilter')
        expect(json_f.errors.first.detail).to eql('Selectedfilter Invalid Query Parameter for filter[selected]')
      end
    end

    describe 'with an invalid query param for filter type within packages query' do
      before do
        VCR.use_cassette(
          'search-providers-related-packages-invalid-filter-type-query-param'
        ) do
          get '/eholdings/providers/19/packages?q=ebsco&filter[type]=invalid', headers: okapi_headers
        end
      end

      let!(:json_f) { Map JSON.parse response.body }

      it 'returns a bad request error' do
        expect(response).to have_http_status(400)
        expect(json_f.errors.first.title).to eql('Invalid contentTypeFilter')
        expect(json_f.errors.first.detail).to eql('Contenttypefilter Invalid Query Parameter for filter[type]')
      end
    end
  end

  describe 'getting a non-existing provider' do
    before do
      VCR.use_cassette('get-provider-not-found') do
        get '/eholdings/providers/1', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
      expect(json.errors.first.title).to eql('Provider not found')
    end
  end

  describe 'updating a provider' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'when the provider does not allow tokens' do
      describe 'setting token value should fail' do
        let(:params) do
          {
            'data' => {
              'type' => 'providers',
              'attributes' => {
                'providerToken' => {
                  'value' => '88'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-providers-isnotallowed-token') do
            put '/eholdings/providers/22',
                params: params, as: :json, headers: update_headers
          end
        end

        let!(:json) { Map JSON.parse response.body }

        it 'responds with bad request' do
          expect(response).to have_http_status(400)
          expect(json.errors.first.title).to eql('Provider does not allow token')
        end
      end
    end

    describe 'when the provider allows tokens' do
      describe 'setting token value should succeed' do
        let(:params) do
          {
            'data' => {
              'type' => 'providers',
              'attributes' => {
                'providerToken' => {
                  'value' => '99'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-providers-token') do
            put '/eholdings/providers/18',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:value) { json.data.attributes.providerToken.value }

        it 'has token value' do
          expect(json.data.attributes.providerToken.value).to eq('99')
        end
      end

      describe 'clearing token value should succeed' do
        let(:params) do
          {
            'data' => {
              'type' => 'providers',
              'attributes' => {
                'providerToken' => {
                  'value' => ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-providers-token-clear') do
            put '/eholdings/providers/18',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:value) { json.data.attributes.providerToken.value }

        it 'has token value' do
          expect(json.data.attributes.providerToken.value).to eq(nil)
        end
      end

      describe 'setting token value exceeding max length should fail' do
        let(:largeToken) { '0' * 501 }

        let(:params) do
          {
            'data' => {
              'type' => 'providers',
              'attributes' => {
                'providerToken' => {
                  'value' => largeToken
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-providers-token-exceeds-max-length') do
            put '/eholdings/providers/18',
                params: params, as: :json, headers: update_headers
          end
        end

        let!(:json) { Map JSON.parse response.body }

        it 'results in error' do
          expect(response).to have_http_status(422)
          expect(json.errors.first.title).to eql('Invalid value')
        end
      end
    end

    describe 'combined update to providers setting token and updating proxy' do
      describe 'setting token value and proxy should succeed' do
        let(:params) do
          {
            'data' => {
              'type' => 'providers',
              'attributes' => {
                'providerToken' => {
                  'value' => '99'
                },
                'proxy' => {
                  'id' => 'TestingFolio'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-providers-token') do
            put '/eholdings/providers/18',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:value) { json.data.attributes.providerToken.value }

        it 'has token value' do
          expect(json.data.attributes.providerToken.value).to eq('99')
        end

        it 'has proxy value with inherited true' do
          expect(json.data.attributes.proxy.id).to eq('TestingFolio')
          expect(json.data.attributes.proxy.inherited).to eq(true)
        end
      end
    end
  end
end
