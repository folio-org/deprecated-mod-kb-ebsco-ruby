# frozen_string_literal: true

class SerializablePackageList < SerializableJSONAPIResource
  type 'packages'

  has_many :resources
  has_one :vendor
  has_one :provider

  attributes :content_type,
             :custom_coverage,
             :is_custom,
             :is_selected,
             :name,
             :proxy,
             :package_id,
             :package_type,
             :provider_id,
             :provider_name,
             :selected_count,
             :title_count

  attribute :vendor_id do
    @object.provider_id
  end

  attribute :vendor_name do
    @object.provider_name
  end

  attribute :visibility_data do
    visibility = @object.visibility_data

    if visibility[:is_hidden]
      visibility[:reason] =
        visibility[:reason] == 'Hidden by EP' ? 'Set by system' : ''
    end
    visibility.transform_keys { |key| key.to_s.camelize(:lower).to_sym }
  end

  attribute :custom_coverage do
    @object.custom_coverage.transform_keys { |key| key.to_s.camelize(:lower).to_sym }
  end

  attribute :content_type do
    content_types = {
      aggregatedfulltext: 'Aggregated Full Text',
      abstractandindex: 'Abstract and Index',
      ebook: 'E-Book',
      ejournal: 'E-Journal',
      print: 'Print',
      unknown: 'Unknown',
      onlinereference: 'Online Reference'
    }

    content_type_key = @object.content_type.downcase.to_sym

    content_types[content_type_key] || @object.content_type
  end
end
