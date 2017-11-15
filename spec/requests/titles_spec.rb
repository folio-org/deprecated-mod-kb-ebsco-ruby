require 'rails_helper'

RSpec.describe "Titles", type: :request do
  let(:okapi_token) { ENV.fetch('TEST_OKAPI_TOKEN') }

  let(:headers) do
    {
      'X-Okapi-Url': 'https://okapi-sandbox.frontside.io',
      'X-Okapi-Tenant': 'fs',
      'X-Okapi-Token': okapi_token
    }
  end


  describe "searching for titles" do
    before do
      VCR.use_cassette("search-titles") do
        get '/eholdings/jsonapi/titles/?q=ebsco', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets a list of resources" do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(25)
      expect(json.meta.totalResults).to equal(60)
    end
  end

  describe "getting a specific title" do
    before do
      VCR.use_cassette("get-titles-success") do
        get '/eholdings/jsonapi/titles/316875', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets the resource" do
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

    it "returns identifiers as human readable types and subtypes" do
      expect(json.data.attributes.identifiers).to include(
        'id' => '316875',
        'type' => 'BHM',
        'subtype' => 'Empty'
        )
    end

    it "returns a human readable publication type" do
      expect(json.data.attributes.publicationType).to eq('Book')
    end
  end

  describe "getting a title with customer resources" do
    before do
      VCR.use_cassette("get-titles-customer-resources") do
        get '/eholdings/jsonapi/titles/316875?include=customerResources', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "includes a list of customers resources" do
      expect(json.data.relationships.customerResources.data.length).to eq(17)
      expect(json.included.length).to eq(17)
    end

    it "returns the correct included type" do
      expect(json.included.first.type).to eq('customerResources')
    end
  end


  describe "getting a non-existing title" do
    before do
      VCR.use_cassette("get-titles-not-found") do
        get '/eholdings/jsonapi/titles/1', headers: headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "returns a not found error" do
      expect(response).to have_http_status(404)
      expect(json.errors).to include(title: 'Title not found')
    end
  end
end
