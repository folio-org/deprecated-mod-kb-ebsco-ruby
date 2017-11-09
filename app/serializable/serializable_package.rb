class SerializablePackage < SerializableResource
  type 'packages'

  attributes :name, 
             :vendor_id, 
             :package_id, 
             :content_type,
             :title_count,
             :selected_count,
             :custom_coverage,
             :visibility_data,
             :is_selected,
             :vendor_name
  
  has_many :customer_resources
end
