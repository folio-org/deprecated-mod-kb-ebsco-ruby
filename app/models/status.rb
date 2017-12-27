# frozen_string_literal: true

class Status
  attr_reader :errors

  def initialize(config)
    @config = config
    @errors = []
  end

  def configuration_valid?
    @config.valid?
  end

  def id
    'status'
  end
end
