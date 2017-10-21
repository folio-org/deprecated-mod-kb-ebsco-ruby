require 'rails_helper'

RSpec.describe "Status", type: :request do
  let(:okapi_token) { ENV.fetch('TEST_OKAPI_TOKEN') }

  let(:resource) do
    [
      '/eholdings/status',
      headers: {
        'X-Okapi-Url': 'https://okapi-sandbox.frontside.io',
        'X-Okapi-Tenant': 'fs',
        'X-Okapi-Token': okapi_token
      }
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
      expect(status["is-configuration-valid"]).to be(true)
      expect(response).to have_http_status(200)
    end
  end
end
