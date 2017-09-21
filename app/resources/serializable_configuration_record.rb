class SerializableConfigurationRecord < SerializableBase
  type 'configuration'

  attributes :api_key, :customer_id

  meta do
    {
      valid: @object.valid?,
      provider: 'mod-kb-ebsco',
      'provider-descriptor': 'Ebsco Knowledge Base'
    }
  end
end
