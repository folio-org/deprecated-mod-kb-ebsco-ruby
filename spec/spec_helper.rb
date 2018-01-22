# frozen_string_literal: true

# If COVERAGE=true, generate simplecov reports
require 'simplecov'
if ENV['COVERAGE']
  SimpleCov.start 'rails' do
    minimum_coverage 90
  end
end

# Shared context for values common to all request tests
RSpec.shared_context 'Request Test Helpers' do
  let!(:customer_id) { ENV.fetch('TEST_CUSTOMER_ID', 'apidvcorp') }
  let!(:api_key) { ENV.fetch('TEST_API_KEY', '4TxhFoiDoxaqz54wspzR074Pw2iUTPZ2arkbnd9N') }
  let!(:okapi_token) { ENV.fetch('TEST_OKAPI_TOKEN', 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsInVzZXJfaWQiOiIxYWQ3MzdiMC1kODQ3LTExZTYtYmYyNi1jZWMwYzkzMmNlMDEiLCJ0ZW5hbnQiOiJmcyJ9.-lRE3mPuJns4cysAV87vy9l7yYMHuwV2JXrpKR9NhBAHafV70SMqWeu1Ixdik5AMNqFt52c8VB1M2RROkamkZw') }
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
    ENV.fetch('TEST_CUSTOMER_ID', 'apidvcorp')
  end
  config.filter_sensitive_data('TEST_API_KEY') do
    ENV.fetch('TEST_API_KEY', '4TxhFoiDoxaqz54wspzR074Pw2iUTPZ2arkbnd9N')
  end
  config.filter_sensitive_data('TEST_OKAPI_TOKEN') do
    ENV.fetch('TEST_OKAPI_TOKEN', 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsInVzZXJfaWQiOiIxYWQ3MzdiMC1kODQ3LTExZTYtYmYyNi1jZWMwYzkzMmNlMDEiLCJ0ZW5hbnQiOiJmcyJ9.-lRE3mPuJns4cysAV87vy9l7yYMHuwV2JXrpKR9NhBAHafV70SMqWeu1Ixdik5AMNqFt52c8VB1M2RROkamkZw')
  end
end
