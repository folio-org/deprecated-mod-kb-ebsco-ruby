require 'rails_helper'

RSpec.describe "Vendors", type: :request do

  describe "searching for vendors" do
    before do
      VCR.use_cassette("search-vendors") do
        get '/eholdings/jsonapi/vendors/?q=ebsco', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets a list of resources" do
      expect(response).to have_http_status(200)
      expect(json.data.length).to equal(2)
      expect(json.meta.totalResults).to equal(2)
    end
  end

  describe "getting a specific vendor" do
    before do
      VCR.use_cassette("get-vendors-success") do
        get '/eholdings/jsonapi/vendors/19', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets the resource" do
      expect(response).to have_http_status(200)
      expect(json.data.type).to eq('vendors')
      expect(json.data.id).to eq('19')
      expect(json.data.attributes).to include('name', 'packagesTotal', 'packagesSelected')
    end

    it "contains relationships data" do
      expect(json.data.relationships). to include('packages')
    end
  end

  describe 'getting a vendor with included packages' do
    before do
      VCR.use_cassette("get-vendors-include-packages-success") do
        get '/eholdings/jsonapi/vendors/19?include=packages', headers: okapi_headers
      end
    end

    let!(:json) { Map JSON.parse response.body }

    it "gets associated package records" do
      expect(response).to have_http_status(200)
      expect(json.included.first.type).to eq('packages')
      expect(json.included.length).to eq(25)
      expect(json.data.relationships.packages.data.length).to eq(25)
    end
  end

  describe "getting a non-existing vendor" do
    before do
      VCR.use_cassette("get-vendors-not-found") do
        get '/eholdings/jsonapi/vendors/1', headers: okapi_headers
      end
    end

    it "returns a not found error" do
      expect(response).to have_http_status(404)
    end
  end
end
