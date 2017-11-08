require 'rails_helper'

RSpec.describe "Status", type: :request do
  let(:resource) do
    [
      '/eholdings/status',
      headers: okapi_headers
    ]
  end

  let(:json) { Map JSON.parse response.body }
  let(:status) { json.data.attributes }

  describe "with valid configuration" do
    before do
      VCR.use_cassette("get-status") do
        get(*resource)
      end
    end

    it "gets configuration validity" do
      expect(status.isConfigurationValid).to be(true)
      expect(response).to have_http_status(200)
    end
  end
end
