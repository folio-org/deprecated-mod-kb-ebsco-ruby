# frozen_string_literal: true

module Validation
  class CustomLabelDestroyParameters
    include ActiveModel::Validations

    attr_accessor :label_id, :custom_label_list

    validates :label_id, presence: true
    validate :label_id_range?
    validate :label_deleted?

    def label_id_range?
      # there can be only 5 custom labels
      errors.add(:label_id, ':Invalid custom label id') unless
        label_id.to_i.between?(1, 5)
    end

    def label_deleted?
      # check if the label has already been deleted
      custom_label_list.each do |label|
        next unless label.id == label_id
        if label.display_label == ''
          errors.add(:label_id, ':Label with this id has already been deleted')
        end
      end
    end

    def initialize(label_id, custom_label_list)
      @label_id = label_id
      @custom_label_list = custom_label_list
    end
  end
end
