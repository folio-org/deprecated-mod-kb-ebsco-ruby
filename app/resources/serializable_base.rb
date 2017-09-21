class SerializableBase < JSONAPI::Serializable::Resource
  extend JSONAPI::Serializable::Resource::KeyFormat

  # This is mildly annoying, but jsonapi-rb does not
  # kebab-case keys by default, despite this being the
  # recommended naming convention for JSON-API.
  # We can override it here, but it's also worth noting
  # this only applies to keys on the model (ergo does not
  # apply to 'meta' properties, etc.)
  key_format -> (key) { key.to_s.dasherize }
end
