# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class CustomPackageParameters
    include ActiveModel::Validations

    attr_accessor :name, :contentType

    validates :name, presence: true
    validates :contentType, presence: true

    # TODO: this should turn snake as soon as it
    # comes out of the deserializable layer.  also
    # we should probably validate more than presence on these.
    # content_type is an enum, and name could be arbitrarily
    # long to the point that RMAPI throws the error instead of us

    def initialize(params = {})
      @name = params[:name]
      @contentType = params[:contentType]
    end
  end
end

# rubocop:enable Naming/VariableName
