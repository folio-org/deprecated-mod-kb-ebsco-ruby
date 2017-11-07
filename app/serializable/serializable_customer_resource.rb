class SerializableCustomerResource < SerializableResource
  type 'customerResources'

  attributes :title_id, 
             :vendor_id, 
             :package_id, 
             :package_name, 
             :is_selected, 
             :selected_count, 
             :title_count
end
