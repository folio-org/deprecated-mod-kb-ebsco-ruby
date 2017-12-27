# frozen_string_literal: true

# Shared context for values common to all request tests
RSpec.shared_context 'Request Test Helpers' do
  let!(:customer_id) { ENV.fetch('TEST_CUSTOMER_ID') }
  let!(:api_key) { ENV.fetch('TEST_API_KEY') }
  let!(:okapi_token) { ENV.fetch('TEST_OKAPI_TOKEN') }
  let!(:okapi_url) { ENV.fetch('TEST_OKAPI_URL', 'https://okapi.frontside.io') }
  let!(:okapi_tenant) { ENV.fetch('TEST_OKAPI_TENANT', 'fs') }

  let!(:okapi_headers) do
    {
      'X-Okapi-Url': okapi_url,
      'X-Okapi-Tenant': okapi_tenant,
      'X-Okapi-Token': okapi_token
    }
  end
end

RSpec.configure do |config|
  # Shared Context Helpers
  config.include_context 'Request Test Helpers', type: :request

  # Assertion / Expectation Settings
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Mocking Behavior
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Causes shared context metadata to be inherited by the
  # metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('TEST_CUSTOMER_ID') do
    ENV['TEST_CUSTOMER_ID']
  end
  config.filter_sensitive_data('TEST_API_KEY') do
    ENV['TEST_API_KEY']
  end
  config.filter_sensitive_data('TEST_OKAPI_TOKEN') do
    ENV['TEST_OKAPI_TOKEN']
  end
end
