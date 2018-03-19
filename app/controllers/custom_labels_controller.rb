# frozen_string_literal: true

class CustomLabelsController < ApplicationController
  def index
    render jsonapi: custom_labels.all, include: params[:include]
  end

  def update # rubocop:disable Metrics/AbcSize
    data_attributes = JSON.parse(request.body.read)['data']['attributes'] || {}
    label_id = params[:id].to_i

    custom_label_validation =
      Validation::CustomLabelUpdateParameters.new(data_attributes, label_id)

    if custom_label_validation.valid?
      @custom_label = custom_labels.update(
        label_id,
        data_attributes
      )
      render jsonapi: @custom_label
    else
      render jsonapi_errors: custom_label_validation.errors,
             status: :unprocessable_entity
    end

  # NoMethodError is raised when [] is invoked on 'data' or
  # `data_attributes` and they are `nil`
  rescue JSON::ParserError, NoMethodError
    error = {
      title: 'Invalid JSON',
      detail: 'The provided JSON payload could not be parsed'
    }

    render jsonapi_errors: [error],
           status: :unprocessable_entity
  end

  def destroy
    label_id = params[:id].to_i

    custom_label_validation =
      Validation::CustomLabelDestroyParameters.new(label_id, custom_labels.all)

    if custom_label_validation.valid?
      custom_labels.delete(label_id)
    else
      render jsonapi_errors: custom_label_validation.errors,
             status: :not_found
    end
  end

  private

  def custom_labels
    CustomLabel.configure config
  end
end
