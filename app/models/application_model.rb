class ApplicationModel
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming
  include ActiveModel::Serialization

  attr_accessor :id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
