# frozen_string_literal: true

class RmApiCustomerRoot < RmApiResource
  request_body_type :json

  get :all, '/'
  put :update, '/'

  # method to update custom label
  def update_label(label_id, attrs)
    # prune the root to not include labels with displayLabel=""
    # because RM API would throw an error in PUT request
    prune(label_id)
    # patch in the new object here
    patch(label_id, attrs)
    # update the root
    update
  end

  # method to prune the request before updating custom labels
  def prune(id)
    labels.delete_if { |item| item.id != id && item.displayLabel == '' }
  end

  # patching the custom label request
  def patch(id, attrs)
    labels.each do |label|
      next unless label.id == id
      label.displayLabel = attrs['displayLabel']
      label.displayOnFullTextFinder = attrs['displayOnFullTextFinder']
      label.displayOnPublicationFinder = attrs['displayOnPublicationFinder']
    end
  end

  def delete_label(label_id)
    # prune the root to not include labels with displayLabel=""
    # because RM API would throw an error in PUT request
    prune(label_id)
    # delete the object that mathces the id
    delete(label_id)
    # update the root
    update
  end

  def delete(label_id)
    # delete a custom label if it matches id passed in
    labels.delete_if { |item| item.id == label_id }
  end

  # method to update root proxy selection
  def update_root_proxy_selection(attrs)
    # update root proxy with the passed value in request
    proxy.id = attrs['id']
    # In RM API, custom labels and root proxy are part of one call
    # we get the data, update what we need and send the data back to not lose it
    # In the get call to RM API, we get display labels that are empty
    # prune any custom labels that do not have display labels; if we do not
    # prune RM API throws an error
    labels.delete_if { |item| item.displayLabel == '' }
    # update the root
    update
  end
end
