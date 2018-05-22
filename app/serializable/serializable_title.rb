# frozen_string_literal: true

class SerializableTitle < SerializableTitleList
  attributes :edition,
             :description,
             :isPeerReviewed

  attribute :contributors do
    @object.contributorsList || []
  end
end
