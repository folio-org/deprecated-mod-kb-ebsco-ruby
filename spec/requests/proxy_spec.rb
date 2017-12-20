require 'rails_helper'

RSpec.describe "Proxy", type: :request do
  describe "getting a vendor" do
    let(:resource) do
      [
        '/eholdings/proxy/vendors/19',
        headers: okapi_headers
      ]
    end

    before do
      VCR.use_cassette("get-proxy-vendor-valid") do
        get(*resource)
      end
    end

    it "gets the vendor" do
      expect(response).to be_ok
    end
  end

  describe "getting a package" do
    let(:resource) do
      [
        '/eholdings/proxy/vendors/19/packages/6581',
        headers: okapi_headers
      ]
    end

    before do
      VCR.use_cassette("get-proxy-package-valid") do
        get(*resource)
      end
    end

    it "gets the package" do
      expect(response).to be_ok
    end
  end

  describe "getting a title" do
    let(:resource) do
      [
        '/eholdings/proxy/titles/316875',
        headers: okapi_headers
      ]
    end

    before do
      VCR.use_cassette("get-proxy-title-valid") do
        get(*resource)
      end
    end

    it "gets the title" do
      expect(response).to be_ok
    end
  end

  describe "getting a customer resource" do
    let(:resource) do
      [
        '/eholdings/proxy/vendors/22/packages/1887786/titles/1440285',
        headers: okapi_headers
      ]
    end
    
    before do
      VCR.use_cassette("get-proxy-customer-resource-valid") do
        get(*resource)
      end
    end

    it "gets the customer resource" do
      expect(response).to be_ok
    end
  end
end
