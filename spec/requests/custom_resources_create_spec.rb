# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Resources Create', type: :request do
  describe 'creating a custom title' do
    let(:create_headers) do
      okapi_headers.merge(
        'Content-Type': 'application/vnd.api+json'
      )
    end

    describe 'with minimum required fields' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing',
              'publicationType' => 'Book',
              'packageId' => 2_843_712
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-name-pubtype') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

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
          'providerId',
          'providerName',
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
      it 'has the new name' do
        expect(json.data.attributes.name).to eq('New Custom Title Testing')
      end

      it 'has the new publication type' do
        expect(json.data.attributes.publicationType).to eq('Book')
      end

      it 'has the newly generated id' do
        expect(json.data.attributes.titleId).to equal(17_098_391)
      end

      it 'has the provider id' do
        expect(json.data.attributes.providerId).to equal(123_355)
      end

      it 'has the composite id' do
        expect(json.data.id).to eq('123355-2843712-17098391')
      end
    end

    describe 'with an existing name' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing',
              'publicationType' => 'Book',
              'packageId' => 2_843_712
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-existing-name') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'responds with bad request' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eql('Custom Title with the provided name already exists')
      end
    end

    describe 'with missing name' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'publicationType' => 'Book',
              'packageId' => 2_843_712
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-missing-name') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid titleName')
      end
    end

    describe 'with a name that exceeds maximum size' do
      let(:largeName) { '0' * 401 }

      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => largeName,
              'publicationType' => 'Book',
              'packageId' => 2_843_712
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-name') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid titleName')
      end
    end

    describe 'with missing publication type' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing',
              'packageId' => '2843712'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-missing-pubtype') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid pubType')
      end
    end

    describe 'with publication type outside list of known values' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing Pub Type',
              'publicationType' => 'Made Up',
              'packageId' => 2_843_712
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-pubtype') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      it 'has unspecified publication type' do
        expect(json.data.attributes.publicationType).to eq('Unspecified')
      end
    end

    describe 'with missing package id' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing',
              'publicationType' => 'Book'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-missing-packageId') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid packageId')
      end
    end

    describe 'with a managed package id' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing',
              'publicationType' => 'Book',
              'packageId' => 2_512_592
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-managed-packageId') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eql('Custom Title can not be added to the provided package')
      end
    end

    describe 'with invalid package id' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'My Custom Title Testing Bad Package Id',
              'publicationType' => 'Book',
              'packageId' => 9_999_999
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-packageId') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eql('Custom Title can not be added to the provided package')
      end
    end

    describe 'with all fields' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'Totally New Custom Title Testing All Fields',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'publisherName' => 'test publisher',
              'isPeerReviewed' => true,
              'edition' => 'test edition',
              'description' => 'test description',
              'url' => 'http://test',
              "customCoverages": [
                {
                  "beginCoverage": '2003-01-01',
                  "endCoverage": '2004-01-01'
                }
              ],
              "contributors": [
                {
                  "type": 'Editor',
                  "contributor": 'some editor'
                },
                {
                  "type": 'Illustrator',
                  "contributor": 'some illustrator'
                }
              ],
              "coverageStatement": 'Test coverage statement',
              "customEmbargoPeriod": {
                "embargoUnit": 'Weeks',
                "embargoValue": 6
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-all-fields') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      it 'has the new resource name' do
        expect(json.data.attributes.name).to eq('Totally New Custom Title Testing All Fields')
      end

      it 'has the new publicationType' do
        expect(json.data.attributes.publicationType).to eq('Book')
      end

      it 'has the new publisherName' do
        expect(json.data.attributes.publisherName).to eq('test publisher')
      end

      it 'has the new isPeerReviewed' do
        expect(json.data.attributes.isPeerReviewed).to eq(true)
      end

      it 'has the new edition' do
        expect(json.data.attributes.edition).to eq('test edition')
      end

      it 'has the new description' do
        expect(json.data.attributes.description).to eq('test description')
      end

      it 'has the new url' do
        expect(json.data.attributes.url).to eq('http://test')
      end

      it 'has the new custom coverage' do
        expect(json.data.attributes.customCoverages[0].beginCoverage)
          .to eq('2003-01-01')
        expect(json.data.attributes.customCoverages[0].endCoverage)
          .to eq('2004-01-01')
      end

      it 'has the list of contributors' do
        expect(json.data.attributes.contributors[0].type)
          .to eq('Editor')
        expect(json.data.attributes.contributors[0].contributor)
          .to eq('some editor')
        expect(json.data.attributes.contributors[1].type)
          .to eq('Illustrator')
        expect(json.data.attributes.contributors[1].contributor)
          .to eq('some illustrator')
      end

      it 'has the new coverageStatement' do
        expect(json.data.attributes.coverageStatement).to eq('Test coverage statement')
      end

      it 'has a custom embargo period' do
        expect(json.data.attributes.customEmbargoPeriod.embargoUnit)
          .to eq('Weeks')
        expect(json.data.attributes.customEmbargoPeriod.embargoValue)
          .to eq(6)
      end
    end

    describe 'with publisher name that exceeds maximum size' do
      let(:largePublisherName) { '0' * 251 }
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Long Publisher',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'publisherName' => largePublisherName
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-publishername') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid publisherName')
      end
    end

    describe 'with peer reviewed that is not true/false' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Peer Review',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'isPeerReviewed' => 'invalid'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-peer-review') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid isPeerReviewed')
      end
    end

    describe 'with edition that exceeds maximum size' do
      let(:largeEdition) { '0' * 251 }
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Edition',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'edition' => largeEdition
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-edition') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid edition')
      end
    end

    describe 'with description that exceeds maximum size' do
      let(:largeDescription) { '0' * 1501 }
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Long Description',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'description' => largeDescription
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-description') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid description')
      end
    end

    describe 'with url that is incorrectly formed' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Invalid Url',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'url' => 'invalid url'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-url') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid url')
      end
    end

    describe 'with url that exceeds maximum size' do
      let(:largeUrl) { '0' * 601 }
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Long Url',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'url' => largeUrl
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-url') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid url')
      end
    end

    describe 'with coverageStatement that exceeds maximum size' do
      let(:largeCoverage) { '0' * 251 }
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Long Coverage',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'coverageStatement' => largeCoverage
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-long-coverage') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid coverageStatement')
      end
    end

    describe 'with invalid embargo' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Invalid Embargo',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              "customEmbargoPeriod": {
                "embargoUnit": 'Seconds',
                "embargoValue": 6
              }
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-embargo') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
      end
    end

    describe 'with invalid coverage' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Invalid Coverage',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              'customCoverages': [
                {
                  'beginCoverage': '99',
                  'endCoverage': '99'
                }
              ]
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-custom-coverage') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
      end
    end

    describe 'with invalid contributor type' do
      let(:params) do
        {
          'data' => {
            'type' => 'resources',
            'attributes' => {
              'name' => 'New Custom Title Testing Invalid Contributor',
              'publicationType' => 'Book',
              'packageId' => 2_843_712,
              "contributors": [
                {
                  "type": 'invalid type',
                  "contributor": 'some editor'
                },
                {
                  "type": 'Illustrator',
                  "contributor": 'some illustrator'
                }
              ]
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-resource-invalid-contributor-type') do
          post '/eholdings/resources',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
      end

      it 'returns expected error message' do
        expect(json.errors.first.title).to eql('Parameter contributorsList.contributorType must be one of (author, editor, illustrator).')
      end
    end
  end
end
