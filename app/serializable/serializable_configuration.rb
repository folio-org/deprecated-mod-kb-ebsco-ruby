# frozen_string_literal: true

class SerializableConfiguration < SerializableJSONAPIResource
  type 'configurations'

  attribute :customer_id

  # The api key is masked in the payload returned from
  # configuration so it cannot be retrieved by unauthorized users
  attribute :api_key do
    '*' * 40
  end
end
