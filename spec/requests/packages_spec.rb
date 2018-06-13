# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Packages', type: :request do
  describe 'searching for packages' do
    before do
      VCR.use_cassette('search-packages') do
        get '/eholdings/packages/?q=ebsco', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets a list of resources' do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(115)
      expect(json.data.first.attributes).to_not include('allowKbToAddTitles')
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('search-packages-page2') do
          get '/eholdings/packages/?q=ebsco&page=2', headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(114)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end
    end
  end

  describe 'filtering by content type' do
    before do
      VCR.use_cassette('search-packages-filter-ebook') do
        filter = { filter: { type: 'ebook' } }.to_query
        get "/eholdings/packages/?q=ebsco&#{filter}", headers: okapi_headers
      end
    end

    let!(:json_f) { Map JSON.parse response.body }

    it 'gets a list of ebook packages' do
      expect(response).to have_http_status(200)
      expect(json_f.data.length).to equal(6)
      expect(json_f.meta.totalResults).to equal(6)
      expect(json_f.data.first.attributes.contentType).to eql('E-Book')
    end

    describe 'filtering further by selected status' do
      before do
        VCR.use_cassette('search-packages-filter-ebook-selection') do
          filter = { filter: { type: 'ebook', selected: true } }.to_query
          get "/eholdings/packages/?q=ebsco&#{filter}", headers: okapi_headers
        end
      end

      let!(:json_f2) { Map JSON.parse response.body }

      it 'gets a list of selected ebook packages' do
        expect(response).to have_http_status(200)
        expect(json_f2.data.length).to equal(1)
        expect(json_f2.meta.totalResults).to equal(1)
        expect(json_f2.data.first.attributes.contentType).to eql('E-Book')
        expect(json_f2.data.first.attributes.isSelected).to be true
      end
    end
  end

  describe 'with an invalid filter param' do
    before do
      VCR.use_cassette('search-packages-filter-invalid') do
        get '/eholdings/packages/?q=ebsco&filter=invalid', headers: okapi_headers
      end
    end

    let!(:json_f) { Map JSON.parse response.body }

    it 'returns a bad request error' do
      expect(response).to have_http_status(422)
      expect(json_f.errors.first.title).to eql('Invalid selectedFilter')
    end
  end

  describe 'with an invalid query param filter[selected]' do
    before do
      VCR.use_cassette('search-packages-invalid-query-param-selected') do
        get '/eholdings/packages/?q=ebsco&filter[selected]=doNotEnter', headers: okapi_headers
      end
    end

    let!(:json_f) { Map JSON.parse response.body }

    it 'returns a bad request error' do
      expect(response).to have_http_status(422)
      expect(json_f.errors.first.title).to eql('Invalid selectedFilter')
    end
  end

  describe 'with an invalid query param filter[type]' do
    before do
      VCR.use_cassette('search-packages-invalid-query-param-type') do
        get '/eholdings/packages/?q=ebsco&filter[type]=doNotEnter', headers: okapi_headers
      end
    end

    let!(:json_f) { Map JSON.parse response.body }

    it 'returns a bad request error' do
      expect(response).to have_http_status(422)
      expect(json_f.errors.first.title).to eql('Invalid contentTypeFilter')
    end
  end

  describe 'with an invalid query param sort' do
    before do
      VCR.use_cassette('search-packages-invalid-query-param-sort') do
        get '/eholdings/packages/?q=ebsco&sort=doNotEnter', headers: okapi_headers
      end
    end

    let!(:json_f) { Map JSON.parse response.body }

    it 'returns a bad request error' do
      expect(response).to have_http_status(422)
      expect(json_f.errors.first.title).to eql('Invalid sortFilter')
    end
  end

  describe 'with alphabetical sorting' do
    before do
      VCR.use_cassette('search-packages-sort-name') do
        get '/eholdings/packages/?q=academic%20search&sort=name',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of alphabetically A-Z sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(186)
      expect(json_n.data.first.type).to eq('packages')
      sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
      expect(json_n.data).to eq(sorted_array)
    end
  end

  describe 'with relevance sorting' do
    before do
      VCR.use_cassette('search-packages-sort-relevance') do
        get '/eholdings/packages/?q=academic%20search&sort=relevance',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of relevancy sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(186)
      expect(json_n.data.first.type).to eq('packages')
      expect(json_n.data[0].attributes.name.downcase).to include(
        'academic search'
      )
      sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
      expect(json_n.data).not_to eq(sorted_array)
    end
  end

  describe 'with default sorting' do
    before do
      VCR.use_cassette('search-packages-sort-default') do
        get '/eholdings/packages/?q=academic%20search',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of relevancy sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(186)
      expect(json_n.data.first.type).to eq('packages')
      expect(json_n.data[0].attributes.name.downcase).to include(
        'academic search'
      )
      sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
      expect(json_n.data).not_to eq(sorted_array)
    end
  end

  describe 'with sorting and no query' do
    before do
      VCR.use_cassette('search-packages-sort-noquery') do
        get '/eholdings/packages/',
            headers: okapi_headers
      end
    end

    let!(:json_n) { Map JSON.parse response.body }

    it 'contains a list of alphabetically sorted resources' do
      expect(response).to have_http_status(200)
      expect(json_n.data.length).to equal(25)
      expect(json_n.meta.totalResults).to equal(10_001)
      expect(json_n.data.first.type).to eq('packages')
      sorted_array = json_n.data.sort_by { |p| p.attributes.name.downcase }
      expect(json_n.data).to eq(sorted_array)
    end
  end

  describe 'getting a specific package' do
    before do
      VCR.use_cassette('get-packages-success') do
        get '/eholdings/packages/19-6581', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('packages')
      expect(json.data.id).to eq('19-6581')
      expect(json.data.attributes).to include(
        'name',
        'contentType',
        'titleCount',
        'selectedCount',
        'customCoverage',
        'visibilityData',
        'isSelected',
        'vendorName',
        'isCustom',
        'packageType',
        'allowKbToAddTitles'
      )
      expect(json.data.attributes.vendorId).to eq(19)
      expect(json.data.attributes.packageId).to eq(6581)
    end

    it 'returns a human readable content type' do
      expect(json.data.attributes.contentType).to eq('Aggregated Full Text')
    end

    it 'returns a valid visibility reason' do
      expect(json.data.attributes.visibilityData.reason).to eq 'Set by system'
    end
  end

  describe 'getting a specific package with allow add titles' do
    before do
      VCR.use_cassette('get-package-allow-add-titles') do
        get '/eholdings/packages/40-1118425', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets the resource' do
      expect(response).to have_http_status(200)
      expect(json.data.attributes.vendorId).to eq(40)
      expect(json.data.attributes.packageId).to eq(1_118_425)
      expect(json.data.attributes.allowKbToAddTitles).to be true
      expect(json.data.attributes.isSelected).to be true
    end
  end

  describe 'getting a package with included resources' do
    before do
      VCR.use_cassette('get-packages-resources') do
        get '/eholdings/packages/19-6581?include=resources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a list of resources' do
      expect(json.data.relationships.resources.data.length).to eq(25)
      expect(json.included.length).to eq(25)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('resources')
    end

    it 'returns empty arrays for array attributes' do
      expect(json.included[8].attributes.contributors).to be_kind_of(Array)
      expect(json.included[8].attributes.subjects).to be_kind_of(Array)
    end
  end

  describe 'getting resources related to package' do
    before do
      VCR.use_cassette('get-packages-related-resources') do
        get '/eholdings/packages/19-6581/resources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'responds with a list of resources' do
      expect(json.data.length).to eq(25)
    end

    it 'returns the correct included type' do
      expect(json.data.first.type).to eq('resources')
    end

    describe 'with pagination' do
      before do
        VCR.use_cassette('get-packages-related-resources-page2') do
          get '/eholdings/packages/19-6581/resources?page=2',
              headers: okapi_headers
        end
      end

      let!(:json2) { Map JSON.parse response.body }

      it 'gets a different list of resources' do
        expect(response).to have_http_status(200)
        expect(json2.data.length).to equal(25)
        expect(json2.meta.totalResults).to equal(157)
        expect(json.data.first.id).not_to eql(json2.data.first.id)
      end
    end

    describe 'with a query' do
      before do
        VCR.use_cassette('get-packages-related-resources-query') do
          get '/eholdings/packages/19-6581/resources/?q=acta',
              headers: okapi_headers
        end
      end

      let!(:json_query) { Map JSON.parse response.body }

      it 'returns list limited to search' do
        expect(json_query.data.length).to eq(1)
        expect(json_query.meta.totalResults).to eq(1)
      end

      describe 'with a invalid filter' do
        before do
          VCR.use_cassette(
            'get-packages-related-resources-query-invalid-sort'
          ) do
            get '/eholdings/packages/19-6581/resources/'\
                 '?q=acta&filter=invalid',
                headers: okapi_headers
          end
        end

        let!(:json_query_invalid_filter) { Map JSON.parse response.body }

        it 'returns a bad request error' do
          title = json_query_invalid_filter.errors.first.title
          expect(response).to have_http_status(400)
          expect(title).to eql('Invalid filter parameter')
        end
      end

      describe 'with valid type filter options ' do
        before do
          VCR.use_cassette(
            'get-packages-related-resources-query-filter-newsletter'
          ) do
            filter = { filter: { type: 'newsletter' } }.to_query
            get '/eholdings/packages/19-6581/resources/'\
                 "?q=bioworld&#{filter}",
                headers: okapi_headers
          end
        end

        let!(:json_query_valid_filter) { Map JSON.parse response.body }

        it 'returns a list limted to filter options passed' do
          expect(response).to have_http_status(200)
          expect(json_query_valid_filter.meta.totalResults).to eql(2)
        end
      end

      describe 'without passing a sort defaults to relevance' do
        before do
          VCR.use_cassette(
            'get-packages-related-resources-query-default-to-relevance'
          ) do
            get '/eholdings/packages/19-6581/resources/'\
                '?q=bioworld%20week',
                headers: okapi_headers
          end
        end

        let!(:json_query_default_relevance) { Map JSON.parse response.body }

        it 'returns a list sorted by relevance' do
          name = json_query_default_relevance.data[0].attributes.name.downcase
          expect(response).to have_http_status(200)
          expect(name).to eql('bioworld week')
        end
      end

      describe 'with passing a sort of name' do
        before do
          VCR.use_cassette(
            'get-packages-related-resources-query-with-name-sort'
          ) do
            get '/eholdings/packages/19-6581/resources/'\
                 '?q=bioworld%20week&sort=name',
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
    end
  end

  describe 'getting resources related to a custom package' do
    before do
      VCR.use_cassette('get-custom-package-related-resources') do
        get '/eholdings/packages/123355-2723775/resources',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'responds with a list of resources' do
      expect(json.data.length).to eq(9)
    end

    it 'does not return identifiers for the resources' do
      expect(json.data.first.attributes.identifiers.length).to eq(0)
    end

    it 'returns the correct included type' do
      expect(json.data.first.type).to eq('resources')
    end
  end

  describe 'getting a package with included vendor' do
    before do
      VCR.use_cassette('get-packages-vendor') do
        get '/eholdings/packages/19-6581?include=vendor',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a vendor' do
      # NOTE: has_one relationships are serialized as singleton hashes
      # there might be a better way to handle this, but for now we
      # wrap the relation in an array

      # rubocop:disable Performance/FixedSize
      expect([json.data.relationships.vendor.data].length).to eq(1)
      # rubocop:enable Performance/FixedSize

      expect(json.included.length).to eq(1)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('vendors')
    end
  end

  describe 'getting a package with correct relationships' do
    before do
      VCR.use_cassette('get-package-relationships') do
        get '/eholdings/packages/19-6581',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes the expected relationships' do
      expect(json.data.relationships).to include(
        'vendor',
        'provider',
        'resources'
      )
    end
  end

  describe 'updating a package' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'when the package is not already selected' do
      describe 'hiding a package should fail' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": false,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isnotselected-toggle-ishidden') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'adding custom coverage should fail' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                },
                "isSelected": false,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isnotselected-add-customcoverage') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'allowing to add titles should fail' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                },
                "isSelected": false,
                "allowKbToAddTitles": true,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isnotselected-allow-add-titles') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'combined update' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                },
                "isSelected": false,
                "allowKbToAddTitles": true,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isnotselected-combined-update') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'selecting a package' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": true,
                "allowKbToAddTitles": true,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isnotselected-toggle-isselected') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }

        it 'is now selected' do
          expect(json.data.attributes.isSelected).to be true
        end
      end
    end

    describe 'when the package is already selected' do
      describe 'hiding a package' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
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
          VCR.use_cassette('put-packages-isselected-toggle-ishidden') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:visibility) { json.data.attributes.visibilityData }

        it 'is still selected' do
          expect(json.data.attributes.isSelected).to be true
        end

        it 'is now hidden' do
          expect(visibility.isHidden).to be true
        end
      end

      describe 'allow kb to add titles to a package' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": true,
                "allowKbToAddTitles": true,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isselected-toggle-add-titles') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }

        it 'is still selected' do
          expect(json.data.attributes.isSelected).to be true
        end

        it 'is allowed to add titles' do
          expect(json.data.attributes.allowKbToAddTitles).to be true
        end
      end

      describe 'adding custom coverage' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                },
                "isSelected": true,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isselected-add-customcoverage') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:coverage) { json.data.attributes.customCoverage }

        it 'is still selected' do
          expect(json.data.attributes.isSelected).to be true
        end

        it 'now has custom coverage' do
          expect(coverage.beginCoverage).to eq('2003-01-01')
          expect(coverage.endCoverage).to eq('2004-01-01')
        end
      end

      describe 'combined update' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                },
                "isSelected": true,
                "allowKbToAddTitles": true,
                "visibilityData": {
                  "isHidden": true,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isselected-combined-update') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:visibility) { json.data.attributes.visibilityData }
        let!(:coverage) { json.data.attributes.customCoverage }

        it 'is selected' do
          expect(json.data.attributes.isSelected).to be true
        end

        it 'is not hidden' do
          expect(visibility.isHidden).to be true
        end

        it 'is allowed to add titles' do
          expect(json.data.attributes.allowKbToAddTitles).to be true
        end

        it 'is populated with custom coverage' do
          expect(coverage.beginCoverage).to eq '2003-01-01'
          expect(coverage.endCoverage).to eq '2004-01-01'
        end
      end

      describe 'deselecting a package' do
        let(:params) do
          {
            "data": {
              "type": 'packages',
              "attributes": {
                "customCoverage": {
                  "beginCoverage": nil,
                  "endCoverage": nil
                },
                "isSelected": false,
                "allowKbToAddTitles": false,
                "visibilityData": {
                  "isHidden": false,
                  "reason": ''
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-packages-isselected-toggle-isselected') do
            put '/eholdings/packages/19-6581',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }

        it 'is not selected' do
          expect(json.data.attributes.isSelected).to be false
        end

        it 'is not hidden' do
          expect(json.data.attributes.visibilityData.isHidden).to be false
        end

        it 'is not allowed to add titles' do
          expect(json.data.attributes.allowKbToAddTitles).to be false
        end
      end
    end
  end

  describe 'getting a non-existing package' do
    before do
      VCR.use_cassette('get-packages-not-found') do
        get '/eholdings/packages/1-1', headers: okapi_headers
      end
    end

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
    end
  end

  describe 'getting a hidden by ep package' do
    before do
      VCR.use_cassette('get-package-reason-hidden-by-ep') do
        get '/eholdings/packages/19-2516',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:visibility) { json.data.attributes.visibilityData }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it 'has reason hidden by customer' do
      expect(visibility.reason).to eq('Set by system')
    end
  end

  describe 'getting a hidden by customer package' do
    before do
      VCR.use_cassette('get-package-reason-hidden-by-customer') do
        get '/eholdings/packages/19-4065',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:visibility) { json.data.attributes.visibilityData }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it 'has reason hidden by customer' do
      expect(visibility.reason).to eq('')
    end
  end

  # RM API will reject PUTs to managed packages
  # with a contentType in the request
  describe 'sending a content type to a managed package' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    let(:params) do
      {
        "data": {
          "type": 'packages',
          "attributes": {
            "name": 'I want to rename this managed package',
            "contentType": 'Book'
          }
        }
      }
    end

    before do
      VCR.use_cassette('put-package-managed-content-type') do
        put '/eholdings/packages/75-2686',
            params: params, as: :json, headers: update_headers
      end
    end

    it 'gets a successful response' do
      expect(response).to have_http_status(400)
    end
  end

  describe 'editing a custom package' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'changing the name' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "isSelected": true,
              "name": 'name of the ages forever and ever',
              "contentType": 'Aggregated Full Text'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-package-name') do
          put '/eholdings/packages/123355-2845506',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has the new name' do
        expect(json.data.attributes.name).to eq('name of the ages forever and ever')
      end
    end

    describe 'changing the coverage dates' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "customCoverage": {
                "beginCoverage": '2003-01-01',
                "endCoverage": '2004-01-01'
              },
              "isSelected": true,
              "name": 'name of the ages forever and ever',
              "contentType": 'Aggregated Full Text'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-package-coverage-dates') do
          put '/eholdings/packages/123355-2845506',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'now has custom coverage' do
        expect(json.data.attributes.customCoverage.beginCoverage)
          .to eq('2003-01-01')
        expect(json.data.attributes.customCoverage.endCoverage)
          .to eq('2004-01-01')
      end
    end

    describe 'changing the content type' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "isSelected": true,
              "name": 'I got a newer package name',
              "contentType": 'Aggregated Full Text'
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-package-content-type') do
          put '/eholdings/packages/123355-2845506',
              params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'has the new content type' do
        expect(json.data.attributes.contentType).to eq('Aggregated Full Text')
      end
    end

    describe 'changing the visibility' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "isSelected": true,
              "name": 'name of the ages forever and ever',
              "contentType": 'Aggregated Full Text',
              "visibilityData": {
                "isHidden": true,
                "reason": ''
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('put-custom-package-visibility') do
          put '/eholdings/packages/123355-2845506',
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
  end

  describe 'deleting a custom package' do
    describe 'delete a custom package successfully' do
      before do
        VCR.use_cassette('delete-custom-package') do
          delete '/eholdings/packages/123355-2848971',
                 headers: okapi_headers
        end
      end

      it 'gets a successful response' do
        expect(response).to have_http_status(204)
      end
    end

    describe 'trying to delete a deleted package results in error' do
      before do
        VCR.use_cassette('delete-deleted-custom-package') do
          delete '/eholdings/packages/123355-2848971',
                 headers: okapi_headers
        end
      end

      it 'gets a not found response' do
        expect(response).to have_http_status(404)
      end
    end

    describe 'trying to delete a non-custom package' do
      before do
        VCR.use_cassette('delete-non-custom-package') do
          delete '/eholdings/packages/583-4345',
                 headers: okapi_headers
        end
      end

      it 'gets a bad request response' do
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'creating a custom package' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'without a packageName' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "contentType": 'ebook'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-package-no-packagename') do
          post '/eholdings/packages/',
               params: params, as: :json, headers: update_headers
        end
      end

      it 'returns an error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'without a contentType' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "name": 'VCR Package 1.1'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-package-no-content-type') do
          post '/eholdings/packages/',
               params: params, as: :json, headers: update_headers
        end
      end

      it 'returns an error' do
        expect(response).to have_http_status(422)
      end
    end

    describe 'that is fully valid' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "name": 'VCR Package 1.6',
              "contentType": 'E-Book',
              "customCoverage": {
                "beginCoverage": '2003-01-01',
                "endCoverage": '2004-01-01'
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-package') do
          post '/eholdings/packages/',
               params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns a fully formed custom package' do
        expect(json.data.attributes.name).to eq 'VCR Package 1.6'
        expect(json.data.attributes.contentType).to eq 'E-Book'
        expect(json.data.attributes.customCoverage.beginCoverage)
          .to eq '2003-01-01'
        expect(json.data.attributes.customCoverage.endCoverage)
          .to eq '2004-01-01'
      end
    end

    describe 'with an already taken name' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "name": 'VCR Package 1.2',
              "contentType": 'E-Book'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-package-taken-name') do
          post '/eholdings/packages/',
               params: params, as: :json, headers: update_headers
        end
      end

      it 'responds with an error' do
        expect(response).to have_http_status(400)
      end
    end

    describe 'giving invalid content type replaces request with Unknown' do
      let(:params) do
        {
          "data": {
            "type": 'packages',
            "attributes": {
              "contentType": 'something',
              "name": 'VCR Package 1.5'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-package-invalid-content-type') do
          post '/eholdings/packages/',
               params: params, as: :json, headers: update_headers
        end
      end

      let!(:json_response) { Map JSON.parse response.body }

      it 'returns success' do
        expect(response).to have_http_status(200)
      end

      it 'content type replaced with Unknown' do
        expect(json_response.data.attributes.contentType).to eql('Unknown')
      end
    end
  end

  describe 'filtering by custom' do
    before do
      VCR.use_cassette('get-all-custom-packages') do
        get '/eholdings/packages?filter[custom]=true&count=100', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'gets a list of custom packages' do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(74)
      expect(json.data.first.attributes.isCustom).to be true
    end
  end
end
