require 'rails_helper'

RSpec.describe "Health", type: :request do
  describe "GET /health" do
    before do
      get '/admin/health'
    end

    it "returns a 200 status code" do
      expect(response).to have_http_status(200)
    end
  end
end
