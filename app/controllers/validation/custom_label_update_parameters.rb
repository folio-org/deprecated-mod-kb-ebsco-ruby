# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class CustomLabelUpdateParameters
    include ActiveModel::Validations

    attr_accessor :label_id,
                  :id,
                  :displayLabel,
                  :displayOnFullTextFinder,
                  :displayOnPublicationFinder

    validates :displayLabel, :id, presence: true
    validate :ids_match?
    validate :id_range?
    validates :displayOnFullTextFinder,
              inclusion: { in: [true, false], message: 'Invalid value' }
    validates :displayOnPublicationFinder,
              inclusion: { in: [true, false], message: 'Invalid value' }

    def ids_match?
      # label_id is what is passed in the url
      # id is what is passed in the payload
      # this should be done in Rails 5 using the following syntax
      # validates :id, numericality: { only_integer:true }
      # But unfortunately, it does not work, hence this is needed
      errors.add(:id, ':Label ids should match') unless
        (id.is_a? Integer) && (id == label_id)
    end

    def id_range?
      # there can be only 5 custom labels
      errors.add(:id, ':Invalid custom label id') unless
        id.to_i.between?(1, 5)
    end

    def initialize(params, label_id)
      @label_id = label_id
      # For consistency, this should be an integer
      @id = params['id']
      @displayLabel = params['displayLabel']
      @displayOnFullTextFinder =
        params['displayOnFullTextFinder']
      @displayOnPublicationFinder =
        params['displayOnPublicationFinder']
    end
  end
end

# rubocop:enable Naming/VariableName
