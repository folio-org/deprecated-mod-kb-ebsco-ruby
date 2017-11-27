require 'rails_helper'

RSpec.describe "Proxy", type: :request do

  let(:resource) do
    [
      '/eholdings/vendors/19',
      headers: okapi_headers
    ]
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
