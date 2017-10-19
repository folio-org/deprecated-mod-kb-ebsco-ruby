require 'rails_helper'

RSpec.describe "Proxy", type: :request do
  let(:okapi_token) { ENV['TEST_OKAPI_TOKEN'] }

  let(:resource) do
    ['/eholdings/vendors/19', headers: {'X-Okapi-Url': 'https://okapi-sandbox.frontside.io', 'X-Okapi-Tenant': 'fs', 'X-Okapi-Token': okapi_token}]
  end

  describe "getting a resource" do
    before do
      VCR.use_cassette("get-resource-valid") do
        get(*resource)
      end
    end

    it "gets the resource" do
      expect(response).to be_ok
    end
  end
end
