# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resources', type: :request do
  describe 'getting a specific resource' do
    before do
      VCR.use_cassette('get-resources-success') do
        get '/eholdings/resources/22-1887786-1440285',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:attributes) { json.data.attributes }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it "is of type 'resources'" do
      expect(json.data.type).to eq('resources')
    end
    it "has a composite id of '{vendor_id}-{package_id}-{title_id}'" do
      expect(json.data.id).to eq('22-1887786-1440285')
    end
    it 'has a list of attributes' do
      expect(attributes).to include(
        'contributors',
        'coverageStatement',
        'customCoverages',
        'customEmbargoPeriod',
        'description',
        'identifiers',
        'isPeerReviewed',
        'isSelected',
        'managedCoverages',
        'managedEmbargoPeriod',
        'name',
        'packageId',
        'packageName',
        'publicationType',
        'publisherName',
        'subjects',
        'titleId',
        'url',
        'vendorId',
        'vendorName',
        'visibilityData',
        'proxy'
      )
    end

    it "has a composite package id of '{vendor_id}-{package_id}'" do
      expect(attributes.packageId).to eq('22-1887786')
    end

    it 'has a human readable publication type' do
      expect(attributes.publicationType).to eq('Book')
    end

    it 'has a selected value' do
      expect(attributes.isSelected).to be true
    end

    it 'has a manage coverage' do
      expect(attributes.managedCoverages.length).to eq(1)
    end

    describe 'with visibility data' do
      it 'has is hidden' do
        expect(attributes.visibilityData).to have_key(:isHidden)
      end
      it 'has reason ' do
        expect(attributes.visibilityData).to have_key(:reason)
      end
      it 'has reason empty' do
        expect(attributes.visibilityData.reason).to eq('')
      end
    end

    describe 'with custom embargo period' do
      it 'has a embargo Unit' do
        expect(attributes.customEmbargoPeriod).to have_key(:embargoUnit)
      end
      it 'has a embargo value' do
        expect(attributes.customEmbargoPeriod).to have_key(:embargoValue)
      end
    end

    describe 'with managed embargo period' do
      it 'has a embargo Unit' do
        expect(attributes.managedEmbargoPeriod).to have_key(:embargoUnit)
      end
      it 'has a embargo value' do
        expect(attributes.managedEmbargoPeriod).to have_key(:embargoValue)
      end
    end

    describe 'with a contributors list' do
      it 'contains contrbutors' do
        expect(attributes.contributors.length).to eq(2)
      end
      it 'contributor has a type' do
        expect(attributes.contributors[0].type).to eq('Author')
      end
      it 'contributor has a name' do
        expect(attributes.contributors[0].contributor).to eq('Havard, Margaret')
      end
    end

    describe 'with an identifiers list' do
      it 'contains identifiers' do
        expect(attributes.identifiers.length).to eq(4)
      end
      it 'identifier has an id' do
        expect(attributes.identifiers[2].id).to eq('978-0-7295-3913-5')
      end
      it 'identifier has a human readable type' do
        expect(attributes.identifiers[2].subtype).to eq('Print')
      end
      it 'identifier has a human readable subtype' do
        expect(attributes.identifiers[2].type).to eq('ISBN')
      end
    end

    describe 'with proxy' do
      it 'contains proxy id' do
        expect(attributes.proxy.id).to eq('EZProxy')
      end
      it 'contains proxy inheritance' do
        expect(attributes.proxy.inherited).to eq(true)
      end
    end
  end

  describe 'getting a resource with included provider' do
    before do
      VCR.use_cassette('get-resources-provider') do
        get '/eholdings/resources/22-1887786-1440285?include=provider',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a provider' do
      # NOTE: has_one relationships are serialized as singleton hashes
      # there might be a better way to handle this, but for now we
      # wrap the relation in an array

      # rubocop:disable Performance/FixedSize
      expect([json.data.relationships.provider.data].length).to eq(1)
      # rubocop:enable Performance/FixedSize

      expect(json.included.length).to eq(1)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('providers')
    end
  end

  describe 'getting a resource with included package' do
    before do
      VCR.use_cassette('get-resources-package') do
        get '/eholdings/resources/22-1887786-1440285?include=package',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a package' do
      # rubocop:disable Performance/FixedSize
      expect([json.data.relationships.package.data].length).to eq(1)
      # rubocop:enable Performance/FixedSize

      expect(json.included.length).to eq(1)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('packages')
    end
  end

  describe 'getting a resource with included title' do
    before do
      VCR.use_cassette('get-resources-title') do
        get '/eholdings/resources/22-1887786-1440285?include=title',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes a title' do
      # rubocop:disable Performance/FixedSize
      expect([json.data.relationships.title.data].length).to eq(1)
      # rubocop:enable Performance/FixedSize

      expect(json.included.length).to eq(1)
    end

    it 'returns the correct included type' do
      expect(json.included.first.type).to eq('titles')
    end
  end

  describe 'getting a resource with correct relationships' do
    before do
      VCR.use_cassette('get-resource-relationships') do
        get '/eholdings/resources/22-1887786-1440285',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it 'includes the expected relationships' do
      expect(json.data.relationships).to include(
        'provider',
        'title',
        'package'
      )
    end
  end

  describe 'trying to get an invalid resource gives the expected errors' do
    describe 'getting a specific resource without title id' do
      before do
        VCR.use_cassette('get-resource-without-title-id') do
          get '/eholdings/resources/22-1887786',
              headers: okapi_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns a 400 bad request error' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eq 'Invalid title_id'
        expect(json.errors.first.detail).to eq 'Title can\'t be blank'
      end
    end

    describe 'getting a specific resource with invalid package id' do
      before do
        VCR.use_cassette('get-resource-with-invalid-package-id') do
          get '/eholdings/resources/22-abcdef-17059786',
              headers: okapi_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns a 400 bad request error' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eq 'Invalid package_id'
        expect(json.errors.first.detail).to eq 'Package :Invalid package id'
      end
    end
  end

  describe 'updating a resource' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'when the resource is not selected' do
      describe 'hiding a resource' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => false,
                'visibilityData' => {
                  'isHidden' => true
                },
                'customEmbargoPeriod' => nil,
                'customCoverages' => []
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resource-isnotselected-ishidden') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'fails with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'setting custom coverages' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => false,
                'visibilityData' => nil,
                'customEmbargoPeriod' => nil,
                'customCoverages' => [
                  {
                    'beginCoverage' => '2001-01-02'
                  },
                  {
                    'beginCoverage' => '2000-01-01',
                    'endCoverage' => '2000-02-01'
                  }
                ]
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resource-isnotselected-customcoverages') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'fails with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'setting a custom embargo period' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => false,
                'visibilityData' => nil,
                'customEmbargoPeriod' => {
                  'embargoUnit' => 'Weeks',
                  'embargoValue' => 6
                },
                'customCoverages' => []
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-isnotselected-customembargo') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'fails with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'setting a coverage statement' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => false,
                'visibilityData' => nil,
                'customEmbargoPeriod' => nil,
                'customCoverages' => [],
                'coverageStatement': 'Only 1980s issues available.'
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-isnotselected-coveragestatement') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'fails with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'selecting a resource' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'proxy' => {
                  'id' => 'EZProxy'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-isselected') do
            put '/eholdings/resources/22-1887786-1440285',
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

    describe 'when the resource is selected' do
      describe 'hiding a resource' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'visibilityData' => {
                  'isHidden' => true
                },
                'proxy' => {
                  'id' => 'EZProxy'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resource-ishidden-update') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:visibility) { json.data.attributes.visibilityData }

        it 'is no longer visible' do
          expect(visibility.isHidden).to be true
        end

        it 'updated proxy correctly' do
          expect(json.data.attributes.proxy.id).to eq('EZProxy')
        end

        it 'does not change inheritance value, always from RM API' do
          expect(json.data.attributes.proxy.inherited).to eq(true)
        end
      end

      describe 'setting custom coverage' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'customCoverages' => [
                  {
                    'beginCoverage' => '2003-01-01',
                    'endCoverage' => '2004-01-01'
                  }
                ],
                'proxy' => {
                  'id' => 'EZProxy'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-customcoverage-update') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:coverages) { json.data.attributes.customCoverages }

        it 'has a custom coverage range' do
          expect(coverages.length).to eq(1)
        end
        it 'custom coverage range has a beginning' do
          expect(coverages[0].beginCoverage).to eq('2003-01-01')
        end
        it 'custom coverage range has an ending' do
          expect(coverages[0].endCoverage).to eq('2004-01-01')
        end
      end

      describe 'setting a custom embargo period' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'customEmbargoPeriod' => {
                  'embargoUnit' => 'Days',
                  'embargoValue' => 7
                },
                'proxy' => {
                  'id' => 'EZProxy'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-customembargo-update') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:embargo) { json.data.attributes.customEmbargoPeriod }

        it 'has a custom embargo period' do
          expect(embargo.embargoUnit).to eq('Days')
          expect(embargo.embargoValue).to eq(7)
        end
      end

      describe 'setting a coverage statement' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'coverageStatement' => 'Only 1990s issues available.'
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-coveragestatement-update') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }

        it 'has a coverage statement' do
          expect(json.data.attributes.coverageStatement)
            .to eq('Only 1990s issues available.')
        end
      end

      describe 'combined update' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'visibilityData' => {
                  'isHidden' => false
                },
                'customEmbargoPeriod' => {
                  'embargoUnit' => 'Months',
                  'embargoValue' => 5
                },
                'customCoverages' => [
                  {
                    'beginCoverage' => '2005-01-01'
                  },
                  {
                    'beginCoverage' => '2000-01-01',
                    'endCoverage' => '2004-02-01'
                  }
                ],
                'coverageStatement' => 'Only 2000s issues available.'
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-combined-update') do
            put '/eholdings/resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with OK status' do
          expect(response).to have_http_status(200)
        end

        let!(:json) { Map JSON.parse response.body }
        let!(:visibility) { json.data.attributes.visibilityData }
        let!(:coverages) { json.data.attributes.customCoverages }
        let!(:embargo) { json.data.attributes.customEmbargoPeriod }

        it 'all fields have been successfully updated' do
          expect(json.data.attributes.isSelected).to be true
          expect(visibility.isHidden).to be false

          expect(coverages.length).to eq(2)
          expect(coverages[0].beginCoverage).to eq('2000-01-01')
          expect(coverages[0].endCoverage).to eq('2004-02-01')

          expect(embargo.embargoUnit).to eq('Months')
          expect(embargo.embargoValue).to eq(5)

          expect(json.data.attributes.coverageStatement)
            .to eq('Only 2000s issues available.')
        end
      end

      describe 'trying to update fields only available to custom resources on a managed title' do
        let(:params) do
          {
            "data": {
              "type": 'resources',
              "attributes": {
                "name": 'I want a cool title name',
                "isPeerReviewed": true,
                "publicationType": 'Newspaper',
                "publisherName": 'Frontside Newspapers',
                "edition": '5',
                "description": 'Something something something',
                "url": 'https://frontside.io',
                "packageId": '19-530'
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-managed-update-custom-fields') do
            put '/eholdings/resources/19-530-417981',
                params: params, as: :json, headers: update_headers
          end
        end

        let!(:json) { Map JSON.parse response.body }

        it 'responds with OK status' do
          expect(response).to have_http_status(422)
          expect(json.errors[0].title).to eq 'Invalid titleName'
          expect(json.errors[0].detail).to eq 'Titlename must be blank'
          expect(json.errors[1].title).to eq 'Invalid isPeerReviewed'
          expect(json.errors[1].detail).to eq 'Ispeerreviewed must be blank'
          expect(json.errors[2].title).to eq 'Invalid pubType'
          expect(json.errors[2].detail).to eq 'Pubtype must be blank'
          expect(json.errors[3].title).to eq 'Invalid publisherName'
          expect(json.errors[3].detail).to eq 'Publishername must be blank'
          expect(json.errors[4].title).to eq 'Invalid edition'
          expect(json.errors[4].detail).to eq 'Edition must be blank'
          expect(json.errors[5].title).to eq 'Invalid description'
          expect(json.errors[5].detail).to eq 'Description must be blank'
          expect(json.errors[6].title).to eq 'Invalid url'
          expect(json.errors[6].detail).to eq 'Url must be blank'
        end
      end

      describe 'updating a resource with an invalid url' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'visibilityData' => {
                  'isHidden' => false
                },
                'customEmbargoPeriod' => {
                  'embargoUnit' => 'Months',
                  'embargoValue' => 5
                },
                'customCoverages' => [
                  {
                    'beginCoverage' => '2005-01-01'
                  },
                  {
                    'beginCoverage' => '2000-01-01',
                    'endCoverage' => '2004-02-01'
                  }
                ],
                'coverageStatement' => 'Only 2000s issues available.',
                'url' => 'not a url'
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resources-update-invalid-url') do
            put '/eholdings/resources/123355-2843714-17059805',
                params: params, as: :json, headers: update_headers
          end
        end

        it 'responds with expected error code' do
          expect(response).to have_http_status(422)
        end

        let!(:json) { Map JSON.parse response.body }

        it 'gives expected error messages in response' do
          expect(json.errors.first.title).to eq 'Invalid url'
          expect(json.errors.first.detail).to eq 'Url has invalid format'
        end
      end
    end

    describe 'trying to update an invalid resource gives the expected errors' do
      describe 'updating a specific resource without title id' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'visibilityData' => {
                  'isHidden' => true
                },
                'proxy' => {
                  'id' => 'EZProxy'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resource-without-title-id') do
            put '/eholdings/resources/22-1887786',
                params: params, as: :json, headers: update_headers
          end
        end

        let!(:json) { Map JSON.parse response.body }

        it 'returns a 400 bad request error' do
          expect(response).to have_http_status(400)
          expect(json.errors.first.title).to eq 'Invalid title_id'
          expect(json.errors.first.detail).to eq 'Title can\'t be blank'
        end
      end

      describe 'updating a specific resource with empty provider id' do
        let(:params) do
          {
            'data' => {
              'type' => 'resources',
              'attributes' => {
                'isSelected' => true,
                'visibilityData' => {
                  'isHidden' => true
                },
                'proxy' => {
                  'id' => 'EZProxy'
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-resource-with-invalid-provider-id') do
            put '/eholdings/resources/abc-1887786-17059786',
                params: params, as: :json, headers: update_headers
          end
        end

        let!(:json) { Map JSON.parse response.body }

        it 'returns a 400 bad request error' do
          expect(response).to have_http_status(400)
          expect(json.errors.first.title).to eq 'Invalid vendor_id'
          expect(json.errors.first.detail).to eq 'Vendor :Invalid vendor id'
        end
      end
    end
  end

  describe 'getting a non-existing resource' do
    before do
      VCR.use_cassette('get-resources-not-found') do
        get '/eholdings/resources/1-1-1',
            headers: okapi_headers
      end
    end

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
    end
  end

  describe 'when the resource is hidden' do
    before do
      VCR.use_cassette('get-resource-reason-hidden-by-customer') do
        get '/eholdings/resources/19-2697502-15097690',
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

  describe 'when the resource is hidden at package level' do
    before do
      VCR.use_cassette('get-resource-reason-hidden-by-ep') do
        get '/eholdings/resources/22-4620-5557625',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:visibility) { json.data.attributes.visibilityData }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it 'has reason hidden by ep' do
      expect(visibility.reason).to eq('Set by system')
    end
  end

  describe 'creating a resource' do
    let(:create_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    let(:package_id) { '19-2516' }
    let(:title_id) { 3_129_599 }
    let(:resource_id) { "#{package_id}-#{title_id}" }

    let(:body) { Map JSON.parse response.body }

    let(:params) do
      {
        data: {
          type: 'resources',
          attributes: {
            packageId: package_id,
            titleId: title_id,
            url: 'http://test.io'
          }
        }
      }
    end

    context 'linking a package that is not a custom package' do
      let(:package_id) { '19-2516' }

      before do
        VCR.use_cassette('resource-link-to-managed-package') do
          post '/eholdings/resources/', params: params, as: :json,
                                        headers: create_headers
        end
      end

      it 'returns some kind of validation error' do
        expect(response).to have_http_status(422)
        expect(body.key?('errors')).to be true
        expect(body.errors.first.detail).to eq 'Packageid Cannot associate Title with a managed Package'
      end
    end
    context 'with a custom package' do
      let(:package_id) { '123355-2864301' }
      before do
        VCR.use_cassette('resource-link-to-custom-package') do
          post '/eholdings/resources/', params: params, as: :json,
                                        headers: create_headers
        end
      end
      it 'returns a 200 response code and the created resource in the body' do
        expect(response).to have_http_status(200)
        expect(body.key?('data')).to be true
        expect(body.data.id).to eq resource_id.to_s
        expect(body.data.attributes.url).to eq 'http://test.io'
      end
      describe 'fetching the resource specified by the newly created id' do
        before do
          VCR.use_cassette('resource-fetch-custom') do
            get "/eholdings/resources/#{resource_id}",
                headers: okapi_headers
          end
        end

        it 'returns the same resource' do
          expect(body.data.id).to eq resource_id
        end
      end
    end

    context 'with an invalid url' do
      let(:package_id) { '123355-2720678' }
      let(:params) do
        {
          data: {
            type: 'resources',
            attributes: {
              packageId: package_id,
              titleId: title_id,
              url: 'not a url'
            }
          }
        }
      end
      before do
        VCR.use_cassette('resource-link-to-custom-package-invalid-url') do
          post '/eholdings/resources/', params: params, as: :json,
                                        headers: create_headers
        end
      end
      it 'returns a 422 status code with a validation error' do
        expect(response).to have_http_status(422)
        expect(body.key?('errors')).to be true
        expect(body.errors.first.detail).to eq 'Url has invalid format'
      end
    end

    context 'without a url' do
      let(:package_id) { '123355-2720678' }
      let(:params) do
        {
          data: {
            type: 'resources',
            attributes: {
              packageId: package_id,
              titleId: title_id
            }
          }
        }
      end
      before do
        VCR.use_cassette('resource-link-to-custom-package-with-empty-url') do
          post '/eholdings/resources/', params: params, as: :json,
                                        headers: create_headers
        end
      end
      it 'returns a 200 response code and the created resource in the body' do
        expect(response).to have_http_status(200)
        expect(body.key?('data')).to be true
        expect(body.data.id).to eq resource_id.to_s
        expect(body.data.attributes.url).to eq nil
      end
    end
  end

  describe 'deleting a resource' do
    describe 'delete a custom resource associated with custom package successfully' do
      before do
        VCR.use_cassette('delete-custom-resource-custom-package') do
          delete '/eholdings/resources/123355-2845510-17059786',
                 headers: okapi_headers
        end
      end

      it 'gets a 204 No Content response' do
        expect(response).to have_http_status(204)
      end
    end

    describe 'trying to delete a deleted resource results in error' do
      before do
        VCR.use_cassette('delete-deleted-custom-resource') do
          delete '/eholdings/resources/123355-2843714-17059786',
                 headers: okapi_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'gets a not found response' do
        expect(response).to have_http_status(404)
        expect(json.errors.first.title).to eq 'Title not found'
      end
    end

    describe 'trying to delete a resource associated with managed package' do
      before do
        VCR.use_cassette('delete-resource-managed-package') do
          delete '/eholdings/resources/117-1757-394532',
                 headers: okapi_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'gets a bad request response' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.detail).to eq 'Resource cannot be deleted'
        expect(json.errors.first.title).to eq 'Invalid resource'
      end
    end

    describe 'trying to delete a resource without providing title id gives expected errors' do
      before do
        VCR.use_cassette('delete-resource-without-title-id') do
          delete '/eholdings/resources/117-394532',
                 headers: okapi_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'gets a bad request response' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.detail).to eq 'Title can\'t be blank'
        expect(json.errors.first.title).to eq 'Invalid title_id'
      end
    end

    describe 'trying to delete a resource with invalid title id gives expected errors' do
      before do
        VCR.use_cassette('delete-resource-with-invalid-title-id') do
          delete '/eholdings/resources/117-394532-abc',
                 headers: okapi_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'gets a bad request response' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.detail).to eq 'Title :Invalid title id'
        expect(json.errors.first.title).to eq 'Invalid title_id'
      end
    end
  end
end
