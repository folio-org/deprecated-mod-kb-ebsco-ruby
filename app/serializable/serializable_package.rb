# frozen_string_literal: true

class SerializablePackage < SerializablePackageList
  attributes :allow_kb_to_add_titles,
             :package_token,
             :proxy

  attribute :package_token do
    @object.package_token&.transform_keys { |key| key.to_s.camelize(:lower).to_sym }
  end
end
