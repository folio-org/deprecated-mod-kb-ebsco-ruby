require 'rails_helper'

RSpec.describe "Customer Resources", type: :request do

  describe "getting a specific customer resource" do
    before do
      VCR.use_cassette("get-customer-resources-success") do
        get '/eholdings/jsonapi/customer-resources/22-1887786-1440285', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }
    let!(:attributes) { json.data.attributes }

    it "gets a successful response" do
      expect(response).to have_http_status(200)
    end
    it "is of type 'customerResources'" do
      expect(json.data.type).to eq('customerResources')
    end
    it "has a composite id of '{vendor_id}-{package_id}-{title_id}'" do
      expect(json.data.id).to eq('22-1887786-1440285')
    end
    it "has a list of attributes" do
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

    it "has a human readable publication type" do
      expect(attributes.publicationType).to eq('Book')
    end

    it "has a selected value" do
      expect(attributes.isSelected).to be true
    end

    it "has a manage coverage" do
      expect(attributes.managedCoverages.length).to eq(1)
    end

    describe "with visibility data" do
      it "has is hidden" do
        expect(attributes.visibilityData).to have_key(:isHidden)
      end
      it "has reason " do
        expect(attributes.visibilityData).to have_key(:reason)
      end
    end

    describe "with custom embargo period" do
      it "has a embargo Unit" do
        expect(attributes.customEmbargoPeriod).to have_key(:embargoUnit)
      end
      it "has a embargo value" do
        expect(attributes.customEmbargoPeriod).to have_key(:embargoValue)
      end
    end

    describe "with managed embargo period" do
      it "has a embargo Unit" do
        expect(attributes.managedEmbargoPeriod).to have_key(:embargoUnit)
      end
      it "has a embargo value" do
        expect(attributes.managedEmbargoPeriod).to have_key(:embargoValue)
      end
    end

    describe "with a contributors list" do
      it "contains contrbutors" do
        expect(attributes.contributors.length).to eq(2)
      end
      it "contributor has a type" do
        expect(attributes.contributors[0].type).to eq('author')
      end
      it "contributor has a name" do
        expect(attributes.contributors[0].contributor).to eq('Havard, Margaret')
      end
    end

    describe "with an identifiers list" do
      it "contains identifiers" do
        expect(attributes.identifiers.length).to eq(4)
      end
      it "identifier has an id" do
        expect(attributes.identifiers[2].id).to eq('978-0-7295-3913-5')
      end
      it "identifier has a human readable type" do
        expect(attributes.identifiers[2].subtype).to eq('Print')
      end
      it "identifier has a human readable subtype" do
        expect(attributes.identifiers[2].type).to eq('ZDBID')
      end
    end
  end

  describe "getting a customer resource with included vendor" do
    before do
      VCR.use_cassette("get-customer-resources-vendor") do
        get '/eholdings/jsonapi/customer-resources/22-1887786-1440285?include=vendor', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "includes a vendor" do
      # NOTE: has_one relationships are serialized as singleton hashes
      # there might be a better way to handle this, but for now we
      # wrap the relation in an array
      expect([json.data.relationships.vendor.data].length).to eq(1)
      expect(json.included.length).to eq(1)
    end

    it "returns the correct included type" do
      expect(json.included.first.type).to eq('vendors')
    end
  end

  describe "getting a customer resource with included package" do
    before do
      VCR.use_cassette("get-customer-resources-package") do
        get '/eholdings/jsonapi/customer-resources/22-1887786-1440285?include=package', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "includes a package" do
      expect([json.data.relationships.package.data].length).to eq(1)
      expect(json.included.length).to eq(1)
    end

    it "returns the correct included type" do
      expect(json.included.first.type).to eq('packages')
    end
    end

  describe "getting a customer resource with included title" do
    before do
      VCR.use_cassette("get-customer-resources-title") do
        get '/eholdings/jsonapi/customer-resources/22-1887786-1440285?include=title', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "includes a title" do
      expect([json.data.relationships.title.data].length).to eq(1)
      expect(json.included.length).to eq(1)
    end

    it "returns the correct included type" do
      expect(json.included.first.type).to eq('titles')
    end
  end

  describe "getting a non-existing customer resource" do
    before do
      VCR.use_cassette("get-customer-resources-not-found") do
        get '/eholdings/jsonapi/customer-resources/1-1-1', headers: okapi_headers
      end
    end

    it "returns a not found error" do
      expect(response).to have_http_status(404)
    end
  end
end
