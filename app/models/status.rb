class Status
  attr_reader :errors

  def initialize(config)
    @errors = []
    @config = config
  end

  def configuration_valid?
    @config.valid?
  end

  def id
    'status'
  end
end
