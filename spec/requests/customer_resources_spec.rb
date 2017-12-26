# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Customer Resources', type: :request do
  describe 'getting a specific customer resource' do
    before do
      VCR.use_cassette('get-customer-resources-success') do
        get '/eholdings/customer-resources/22-1887786-1440285',
            headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:attributes) { json.data.attributes }

    it 'gets a successful response' do
      expect(response).to have_http_status(200)
    end
    it "is of type 'customerResources'" do
      expect(json.data.type).to eq('customerResources')
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
        'visibilityData'
      )
    end

    it "has a composite pacakge id of '{vendor_id}-{package_id}'" do
      expect(attributes.packageId).to eq('22-1887786')
    end

    it 'has a human readable publication type' do
      expect(attributes.publicationType).to eq('Book')
    end

    it 'has a selected value' do
      expect(attributes.isSelected).to be false
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
        expect(attributes.contributors[0].type).to eq('author')
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
        expect(attributes.identifiers[2].type).to eq('ZDBID')
      end
    end
  end

  describe 'getting a customer resource with included vendor' do
    before do
      VCR.use_cassette('get-customer-resources-vendor') do
        get '/eholdings/customer-resources/22-1887786-1440285?include=vendor',
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

  describe 'getting a customer resource with included package' do
    before do
      VCR.use_cassette('get-customer-resources-package') do
        get '/eholdings/customer-resources/22-1887786-1440285?include=package',
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

  describe 'getting a customer resource with included title' do
    before do
      VCR.use_cassette('get-customer-resources-title') do
        get '/eholdings/customer-resources/22-1887786-1440285?include=title',
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

  describe 'updating a customer resource' do
    let(:update_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'when the customer resource is not selected' do
      describe 'hiding a customer resource' do
        let(:params) do
          {
            'data' => {
              'type' => 'customerResources',
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
          VCR.use_cassette('put-customer-resource-isnotselected-ishidden') do
            put '/eholdings/customer-resources/22-1887786-1440285',
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
              'type' => 'customerResources',
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
          # rubocop:disable Metrics/LineLength
          VCR.use_cassette('put-customer-resource-isnotselected-customcoverages') do
            put '/eholdings/customer-resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
          # rubocop:enable Metrics/LineLength
        end

        it 'fails with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'setting a custom embargo period' do
        let(:params) do
          {
            'data' => {
              'type' => 'customerResources',
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
          # rubocop:disable Metrics/LineLength
          VCR.use_cassette('put-customer-resources-isnotselected-customembargo') do
            put '/eholdings/customer-resources/22-1887786-1440285',
                params: params, as: :json, headers: update_headers
          end
          # rubocop:enable Metrics/LineLength
        end

        it 'fails with unprocessable entity status' do
          expect(response).to have_http_status(422)
        end
      end

      describe 'selecting a customer resource' do
        let(:params) do
          {
            'data' => {
              'type' => 'customerResources',
              'attributes' => {
                'isSelected' => true
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-customer-resources-isselected') do
            put '/eholdings/customer-resources/22-1887786-1440285',
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

    describe 'when the customer resource is selected' do
      describe 'hiding a customer resource' do
        let(:params) do
          {
            'data' => {
              'type' => 'customerResources',
              'attributes' => {
                'isSelected' => true,
                'visibilityData' => {
                  'isHidden' => true
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-customer-resource-ishidden-update') do
            put '/eholdings/customer-resources/22-1887786-1440285',
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
      end

      describe 'setting custom coverage' do
        let(:params) do
          {
            'data' => {
              'type' => 'customerResources',
              'attributes' => {
                'isSelected' => true,
                'customCoverages' => [
                  {
                    'beginCoverage' => '2003-01-01',
                    'endCoverage' => '2004-01-01'
                  }
                ]
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-customer-resources-customcoverage-update') do
            put '/eholdings/customer-resources/22-1887786-1440285',
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
              'type' => 'customerResources',
              'attributes' => {
                'isSelected' => true,
                'customEmbargoPeriod' => {
                  'embargoUnit' => 'Days',
                  'embargoValue' => 7
                }
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-customer-resources-customembargo-update') do
            put '/eholdings/customer-resources/22-1887786-1440285',
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

      describe 'combined update' do
        let(:params) do
          {
            'data' => {
              'type' => 'customerResources',
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
                ]
              }
            }
          }
        end

        before do
          VCR.use_cassette('put-customer-resources-combined-update') do
            put '/eholdings/customer-resources/22-1887786-1440285',
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
        end
      end
    end
  end

  describe 'getting a non-existing customer resource' do
    before do
      VCR.use_cassette('get-customer-resources-not-found') do
        get '/eholdings/customer-resources/1-1-1',
            headers: okapi_headers
      end
    end

    it 'returns a not found error' do
      expect(response).to have_http_status(404)
    end
  end
end
