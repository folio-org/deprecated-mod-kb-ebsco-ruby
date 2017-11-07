class SerializableTitle < SerializableResource
  type 'titles'

  attributes :name,
             :description,
             :publisher_name,
             :publication_type,
             :is_title_custom,
             :is_peer_reviewed,
             :contributors,
             :identifiers,
             :subjects

  has_many :customer_resources
end
