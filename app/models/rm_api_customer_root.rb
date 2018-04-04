# frozen_string_literal: true

class RmApiCustomerRoot < RmApiResource
  request_body_type :json

  get :all, '/'
  put :update, '/'

  def update_label(label_id, attrs)
    # prune the root to not include labels with displayLabel=""
    # because RM API would throw an error in PUT request
    prune(label_id)
    # patch in the new object here
    patch(label_id, attrs)
    # update the root
    update
  end

  def prune(id)
    labels.delete_if { |item| item.id != id && item.displayLabel == '' }
  end

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
end
