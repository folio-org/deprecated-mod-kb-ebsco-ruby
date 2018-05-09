# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Titles Create', type: :request do
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing',
              'publicationType' => 'Book'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-name-pubtype') do
          post '/eholdings/titles',
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
          'description',
          'identifiers',
          'isPeerReviewed',
          'isTitleCustom',
          'name',
          'publicationType',
          'publisherName',
          'subjects'
        )
      end

      it 'has the new name' do
        expect(json.data.attributes.name).to eq('New Title Testing')
      end

      it 'has the new publication type' do
        expect(json.data.attributes.publicationType).to eq('Book')
      end

      it 'has the newly generated id' do
        expect(json.data.id).to eq('17239271')
      end
    end

    describe 'with an existing name' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing',
              'publicationType' => 'Book'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-existing-name') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'publicationType' => 'Book'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-missing-name') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => largeName,
              'publicationType' => 'Book'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-long-name') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'My Title Testing'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-missing-pubtype') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'My Title Testing Pub Type',
              'publicationType' => 'Made Up'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-pubtype') do
          post '/eholdings/titles',
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

    describe 'with missing included resource' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'My Title Testing',
              'publicationType' => 'Book'
            }
          }
        }
      end

      before do
        VCR.use_cassette('post-custom-title-missing-resource') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(400)
        expect(json.errors.first.title).to eql('Missing resource')
      end
    end

    describe 'with missing package id' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'My Title Testing Bad Package Id',
              'publicationType' => 'Book'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {}
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-missing-packageId') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'My Title Testing',
              'publicationType' => 'Made Up'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2512592'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-managed-packageId') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'My Title Testing Bad Package Id',
              'publicationType' => 'Made Up'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '9999999-9999999'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-packageId') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(404)
        expect(json.errors.first.title).to eql('Provider not found')
      end
    end

    describe 'with all fields' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'Totally New Title Testing All Fields',
              'publicationType' => 'Book',
              'publisherName' => 'test publisher',
              'isPeerReviewed' => true,
              'edition' => 'test edition',
              'description' => 'test description',
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
              "identifiers": [
                {
                  "id": '12347',
                  "type": 'ISBN',
                  "subtype": 'Print'
                },
                {
                  "id": '98547',
                  "type": 'ISSN',
                  "subtype": 'Online'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-all-fields') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      it 'has the new resource name' do
        expect(json.data.attributes.name).to eq('Totally New Title Testing All Fields')
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

      it 'has the list of contributors' do
        expect(json.data.attributes.contributors[0].type)
          .to eq('editor')
        expect(json.data.attributes.contributors[0].contributor)
          .to eq('some editor')
        expect(json.data.attributes.contributors[1].type)
          .to eq('illustrator')
        expect(json.data.attributes.contributors[1].contributor)
          .to eq('some illustrator')
      end

      it 'has the list of identifiers' do
        expect(json.data.attributes.identifiers[0].id)
          .to eq('12347')
        expect(json.data.attributes.identifiers[0].type)
          .to eq('ISBN')
        expect(json.data.attributes.identifiers[0].subtype)
          .to eq('Print')
        expect(json.data.attributes.identifiers[1].id)
          .to eq('98547')
        expect(json.data.attributes.identifiers[1].type)
          .to eq('ISSN')
        expect(json.data.attributes.identifiers[1].subtype)
          .to eq('Online')
      end
    end

    describe 'with publisher name that exceeds maximum size' do
      let(:largePublisherName) { '0' * 251 }
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Long Publisher',
              'publicationType' => 'Book',
              'publisherName' => largePublisherName
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-long-publishername') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Peer Review',
              'publicationType' => 'Book',
              'isPeerReviewed' => 'invalid'
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-peer-review') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Edition',
              'publicationType' => 'Book',
              'edition' => largeEdition
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-long-edition') do
          post '/eholdings/titles',
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
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Custom Title Testing Long Description',
              'publicationType' => 'Book',
              'description' => largeDescription
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-long-description') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
        expect(json.errors.first.title).to eql('Invalid description')
      end
    end

    describe 'with invalid contributor type' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Invalid Contributor',
              'publicationType' => 'Book',
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
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-contributor-type') do
          post '/eholdings/titles',
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

    describe 'with empty contributors and identifiers' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Invalid Contributor Uh-huh',
              'publicationType' => 'Book',
              "contributors": [],
              "identifiers": []
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-empty-contributors-identifiers') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'with invalid identifier id' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Invalid Identifier Id',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "id": 12_345, # cannot be an integer, has to be a string
                  "type": 'ISBN',
                  "subtype": 'Print'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-identifier-id') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
      end

      it 'returns expected error message title' do
        expect(json.errors.first.title).to eql('Invalid IdentifierId')
      end
    end

    describe 'with invalid identifier id length' do
      let(:longIdentifierId) { '0' * 21 }
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Invalid Identifier Id Length',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "id": longIdentifierId,
                  "type": 'ISBN',
                  "subtype": 'Print'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-identifier-id-length') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
      end

      it 'returns expected error message title' do
        expect(json.errors.first.title).to eql('Invalid IdentifierId')
      end
    end

    describe 'with missing identifier id' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Missing Identifier Id',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "type": 'ISBN',
                  "subtype": 'Print'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-missing-identifier-id') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
      end

      it 'returns expected error message title' do
        expect(json.errors.first.title).to eql('Invalid IdentifierId')
      end
    end

    describe 'with invalid identifier type' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Invalid Identifier Type',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "id": '12345',
                  "type": 'Invalid Type',
                  "subtype": 'Print'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-identifier-type') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
      end

      it 'returns expected error message title' do
        expect(json.errors.first.title).to eql('Invalid IdentifierType')
      end
    end

    describe 'with valid identifier types' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Valid Identifier Types',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "id": '12345',
                  "type": 'ISSN',
                  "subtype": 'Print'
                },
                {
                  "id": '12345',
                  "type": 'ISBN',
                  "subtype": 'Print'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-valid-identifier-types') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      it 'has the expected list of identifiers' do
        expect(json.data.attributes.identifiers[0].id)
          .to eq('12345')
        expect(json.data.attributes.identifiers[0].type)
          .to eq('ISSN')
        expect(json.data.attributes.identifiers[0].subtype)
          .to eq('Print')
        expect(json.data.attributes.identifiers[1].id)
          .to eq('12345')
        expect(json.data.attributes.identifiers[1].type)
          .to eq('ISBN')
        expect(json.data.attributes.identifiers[1].subtype)
          .to eq('Print')
      end
    end

    describe 'with invalid identifier subtype' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Invalid Identifier Type',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "id": '12345',
                  "type": 'ISSN',
                  "subtype": 'Invalid subtype'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-invalid-identifier-type') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
      end

      it 'returns expected error message title' do
        expect(json.errors.first.title).to eql('Invalid IdentifierSubType')
      end
    end

    describe 'with valid identifier subtypes' do
      let(:params) do
        {
          'data' => {
            'type' => 'titles',
            'attributes' => {
              'name' => 'New Title Testing Valid Identifier SubTypes',
              'publicationType' => 'Book',
              "identifiers": [
                {
                  "id": '12345',
                  "type": 'ISSN',
                  "subtype": 'Print'
                },
                {
                  "id": '12345',
                  "type": 'ISBN',
                  "subtype": 'Online'
                }
              ]
            }
          },
          'included' => [
            {
              'type' => 'resources',
              'attributes' => {
                'packageId' => '123355-2845504'
              }
            }
          ]
        }
      end

      before do
        VCR.use_cassette('post-custom-title-valid-identifier-subtypes') do
          post '/eholdings/titles',
               params: params, as: :json, headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'responds with OK status' do
        expect(response).to have_http_status(200)
      end

      let!(:json) { Map JSON.parse response.body }
      let!(:attributes) { json.data.attributes }

      it 'has the expected list of identifiers' do
        expect(json.data.attributes.identifiers[0].id)
          .to eq('12345')
        expect(json.data.attributes.identifiers[0].type)
          .to eq('ISSN')
        expect(json.data.attributes.identifiers[0].subtype)
          .to eq('Print')
        expect(json.data.attributes.identifiers[1].id)
          .to eq('12345')
        expect(json.data.attributes.identifiers[1].type)
          .to eq('ISBN')
        expect(json.data.attributes.identifiers[1].subtype)
          .to eq('Online')
      end
    end

    describe 'with an invalid payload' do
      before do
        VCR.use_cassette('post-custom-title-invalid-payload') do
          post '/eholdings/titles', headers: create_headers
        end
      end

      let!(:json) { Map JSON.parse response.body }

      it 'returns an error status' do
        expect(response).to have_http_status(422)
      end

      it 'returns expected error message title' do
        expect(json.errors.first.title).to eql('Invalid JSON')
      end
    end
  end
end
