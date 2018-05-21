# Route Architecture Case Study: Packages

## Context
At first glance, [UIEH-287](https://issues.folio.org/browse/UIEH-287) did not appear to be the pivotal ticket it would wind up becoming.  It boils down to two smaller tasks:

The **first** task (filtering by custom status) was the first time we'd be implementing a filter's business logic in the `mod-kb-ebsco` layer.  Typically these filter options have been forwarded directly to RMAPI, but in this case `custom` was not supported.  Compounding things further: due to RMAPI's page limit of 100 records, there was a possibility that we would have to aggregate the results of several RMAPI requests until all the pages of records had been consumed.  This repeated polling was also a first.

**Secondly** the mechanism by which existing titles (managed or custom) could be linked to custom packages was best expressed by something like:

```
POST /resources

'data': {
	'attributes': {
		'packageId': // (new package id)
		'titleId': // (same title id)
	}
}
```

By going this route we are strongly defining "resource" (a term we often overload in this ecosystem) as a relationship between package and title, and _only_ said relationship.  Prior to this we had normalized titles and their `customerResources` property into a single API resonse representing a resource (or "package/title").  The `POST` to `/resource`, (though seeming unused anywhere by `ui-eholdings`) was already implemented, and accepted a normalized payload commensurate with our previous understanding and representation of "resources".  Once we had to account for custom titles and the divide between title-level and resource-level field edits, this endpoint became obsolete and was replaced.

It is the first task on which this document will focus.  Though I didn't set out intending for said task to include a rather large refactor of the Packages route from top to bottom, that is what it eventually snowballed into.  We met an impasse while trying to determine where and how to place the logic around pulling records beyond the page limit, and one gross underesimation later we wound up with an entirely new approach to persistence - one that is ultimately better suited to brokering communication with RMAPI.


##  Context: Known Pain Points

There's been a lot of chatter about moving away from the use of [Flexirest](https://github.com/flexirest/flexirest) in our models.  While there are certainly complaints to be made about this gem, the pain we experienced came largely from the [Active Record](https://martinfowler.com/eaaCatalog/activeRecord.html) pattern that Flexirest sought to emulate.  Most Rails apps are database backed, and most utilize [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) for persistence.  ActiveRecord is an incredible [ORM](https://en.wikipedia.org/wiki/Object-relational_mapping), but it is designed to map tightly to a (preferably well-defined) relational database.  When that database is not so well-defined (which is many if not most of them in the real world), ActiveRecord offers some lower level tools for directly manipulating queries.  But usually it doesn't get that far - one of ActiveRecord's primary strengths is its query generation.

But `mod-kb-ebsco` is not a typical Rails application.  It's a Rails API that brokers its persistence through other APIs: RMAPI primarily, but we should not discount communication with sibling services in the Okapi cluster (for now just `mod-configuration`).  _Flexirest_'s primary assumption is that instead of a database, it would handle persistence through a RESTful API.  There are several such gems in this vein, and Flexirest is probably the most flexible even now.  Sadly, RMAPI is not purely RESTful - and this is not unusual in enterprise software of a certain age.

It became clearer and clearer as our `before_request` blocks grew that mapping a record from RMAPI to a ruby object, merging in some validated updates, and then firing the model back at RMAPI with a generic `.save` method was not going to cut it.  We learned this early on upon discovering that a  `PUT` to an RMAPI endpoint could receive a success response (204 No Content) even though only a portion of the update succeeded.  To work around this we had to follow every mutation up with another fetch.

Query params are interdependent, and so require at the very least a name change and often some busines logic.  And thus the `before_request` blocks grew and grew - often with much overlap between each other.

For packages and resources both there are discrete "bodyoption" definitions for payloads that RMAPI accepts for updates.  Really what we're dealing with is a _second_ serialization layer: the one between `mod-kb-ebsco` and RMAPI.  Unlike the serialization layer we use between `mod-kb-ebsco` and the user - the layer betwen `mod-kb-ebsco` and RMAPI was being handled ad-hoc, usually by combining Strong Parameters in the controller and then `slice`ing the model's attributes into a hash that conformed to one of RMAPI's "bodyoptions":

`/app/models/resource.rb`
```ruby
    self.class.update(
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId,
      isSelected: resource_attributes[:isSelected],
      isHidden: resource_attributes[:visibilityData][:isHidden],
      customCoverageList: sorted_coverage,
      contributorsList: resource_attributes[:contributorsList],
      identifiersList: resource_attributes[:identifiersList],
      customEmbargoPeriod: resource_attributes[:customEmbargoPeriod],
      coverageStatement: resource_attributes[:coverageStatement],
      titleName: attributes[:titleName],
      pubType: attributes[:pubType],
      isPeerReviewed: attributes[:isPeerReviewed],
      publisherName: attributes[:publisherName],
      edition: attributes[:edition],
      description: attributes[:description],
      url: resource_attributes[:url]
    )
```

This is even more unweildy when accessed via the corresponding instance method.  That snippet above comes from a larger flow for updating a Resource record:

```ruby
  # Instance methods
  def update(params)
    # Mimicking AR as closely as we can here. Invoking `update` on a
    # model (i.e. as an instance method) applies a hash of changes
    # to the instance and then persists that data to the store.
    merge_fields!(params)
    save!
  end

  def save!
    attributes = update_fields
    resource_attributes = resource_update_fields

    self.class.update(
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId,
      isSelected: resource_attributes[:isSelected],
      isHidden: resource_attributes[:visibilityData][:isHidden],
      customCoverageList: sorted_coverage,
      contributorsList: resource_attributes[:contributorsList],
      identifiersList: resource_attributes[:identifiersList],
      customEmbargoPeriod: resource_attributes[:customEmbargoPeriod],
      coverageStatement: resource_attributes[:coverageStatement],
      titleName: attributes[:titleName],
      pubType: attributes[:pubType],
      isPeerReviewed: attributes[:isPeerReviewed],
      publisherName: attributes[:publisherName],
      edition: attributes[:edition],
      description: attributes[:description],
      url: resource_attributes[:url]
    )
    refresh!
  end

  def refresh!
    # re-fetch from RM API to surface side-effects
    saved = self.class.find(
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId
    )
    merge_fields!(saved.resource)
  end

```

In a database-backed ActiveRecord model (which maps to single table row), each field would map directly to a field in that table's row.  But due to RMAPI's caveats about what fields can be updated and when they can be updated, this pattern begins to break down.

With a database:
```ruby
user = User.find(1)
user.update(name: 'tony jr.')
```
```sql
INSERT INTO users (name) VALUES ('tony jr.');
```

With RMAPI, simply passing the attribute through (after validation) wouldn't work the same way:
```ruby
resource = Resource.find('1-2-3')
resource.update(custom_embargo_period: '1 Week')
```
```
PUT /vendors/1/packages/2/titles/3
{
  customEmbargoPeriod: '1 Week'
}

500: "Missing Attribute: isSelected"
```

Over time it became clear that the Active Record pattern didn't really serve our needs, and we often found ourselves dancing around it.

## Implementation Diary
Elrick and I had paired one of his tickets earlier in the day, so he joined me on my initial journey into the ticket.  Once we got to the model layer, after quite a bit of discussion, we were at a loss of how to proceed.

Our biggest concern was the use case that may require multiple calls to RMAPI.  To do that from inside the model (i.e. inside the instance method `@resource.update`) would be difficult if not impossible.  This would mean somehow plucking `filter[custom]` before it hit `before_request` and then holding onto it in some sort of private attribute until the cycle of requests was complete, and then releasing it.  Or something like that.  It would've been pretty inscrutable to anybody seeing it for the first time, had we actually found a way to  implement it.

I played around with callbacks here too.  I'm ashamed to admit I even considered `after_request` I but couldn't get it to work.  Even if i had, callbacks in ActiveRecord models _suck_ [citation needed].

Getting ahold of `filters[custom]` and reacting to it could be done in the controller, but this too felt somewhat awkward.  We'd have to branch off there and call a) a _service object_* or b) another class method on the model.

[*] This is what we should've done, in retrospect.  Had I known the implementation I went with would take as long as it did, I would've just done this given the importance of the deadline.

By the time the day ended, I decided to sketch out what an ideal design for a route might look like that evening, and by the time I was finished witing it out it seemed like would be able to be implemented within the sprint with time to spare. In the spirit of incremental refactoring I decided to only port over the portions of my design that were necessary to the feature, but ultimately those pieces were more intertwined than I had expected so the overhaul became larger and larger.  And there are still chunks that didn't make it in - either because they turned out to be over-abstractions or because we didn't have time to implement them.


## Architectural Overview

The primary criticism raised about the Active Record pattern is that models are responsible both for holding their state and for retrieving/manipulating their state.  These concerns should be separated.  Doing this would allow us to face the complexities of our persistence layer face-to-face rather than through an army of shapeshifting models.

- **Models** now _purely_ model data.  They are literally just a list of the properties and relationships.

This frees models from having to worry about their own persistence - especially in different contexts.  It doensn't have to cut itself up one way for an `update` or another for a `delete`.  Instead they're just a clean model of the data we care about:
```ruby
class Package
  include ActiveAttr::Model

  alias_attribute :vendor_id, :provider_id
  alias_attribute :vendor_name, :provider_name

  attribute :allow_kb_to_add_titles
  attribute :content_type
  attribute :custom_coverage, default: -> { CustomCoverage.new }
  attribute :is_custom
  attribute :is_selected
  attribute :name
  attribute :package_id
  attribute :package_type
  attribute :provider_id
  attribute :provider_name
  attribute :selected_count
  attribute :title_count
  attribute :provider_id
  attribute :provider_name
  attribute :visibility_data, default: -> { VisibilityData.new }

  class VisibilityData
    include ActiveAttr::Model

    attribute :is_hidden
    attribute :reason
  end

  class CustomCoverage
    include ActiveAttr::Model

    attribute :begin_coverage
    attribute :end_coverage
  end

  def id
    "#{provider_id}-#{package_id}"
  end

  # Relationships
  def vendor
    @vendors.find provider_id
  end

  def provider
    @providers.find provider_id
  end

  def resources
    find_resources.titles.to_a
  end

  def find_resources(**params)
    @resources.find_by_package(vendor_id: provider_id, package_id: package_id, **params)
  end
end
```

- All persistence is now handled through **Repositories**.  These expose a CRUD interface at minimum, but also allow us to extend beyond that into complex interactions to handle complex operations or edge cases.  The Repository has its finger on the pulse of the data model, and everything that rests on top of it need not concern itself with the details of how it is stored.
	- As more routes are moved towards this pattern, a superclass would be useful to handle configuration and to enforce an interface for the subclasses.
- As a result of moving all of this logic to the Repository, our controllers are now very clean:

```ruby
def index
  @result = packages.where! params
  render jsonapi: @result.data, meta: @result.meta
end

def show
  @result = packages.find! params[:id]
  render jsonapi: @result.data, include: params[:include]
end

def create
  @result = packages.create! package_create_params
  render jsonapi: @result.data
end

def update
  @result = packages.update! params[:id], package_update_params
  render jsonapi: @result.data
end

def destroy
  packages.destroy! params[:id]
end

private

def packages
  PackagesRepository.new(config: config)
end
```


## Missing Pieces

### Serialization to RMAPI

This was one of the main goals of the refactor in the first place - we have a full-blown serialization layer between `mod-kb-ebsco` and the consumer, but preparing updates from RMAPI is an inconsistent mix of Strong Parameter declarations in the controller level, validations that are dialed in to the controller, and explicit subsets of attributes that are listed out in the models.

If you take a look at our current implementation of PackagesRepository, it isn't much different.  By the time it gets to the repository, the incoming data has been trimmed by strong params at the controller level:

*packges_controller.rb*
```ruby
  def package_params
    params
      .require(:package)
      .permit(
        :name,
        :contentType,
        :isSelected,
        :allowKbToAddTitles,
        visibilityData: [:isHidden],
        customCoverage: %i[beginCoverage endCoverage]
      )
  end

  def package_create_params
    package_params.slice(:name, :contentType, :customCoverage)
  end

  def package_update_params
    if package.is_custom
      package_params
    else
      package_params.except(:name, :contentType)
    end
  end
```

So `attrs` here is a subset of the resource's fields.  Now in the Repository, you can see the mapping is not much better than what we had.  This was due to time constraints.  If you've got a good eye, you'll see the cause of UIEH-361 in here:

```ruby
 def update!(id, attrs)
    request do
      package_validation = Validation::PackageParameters.new(attrs)
      fail ValidationError, package_validation unless package_validation.valid?

      vendor_id, package_id = id.split('-')

      payload = attrs.to_hash.deep_symbolize_keys
      payload[:allowEbscoToAddTitles] = payload.delete(:allowKbToAddTitles)
      payload[:packageName] = payload.delete(:name)
      payload[:isHidden] = payload.dig(:visibilityData, :isHidden)
      payload.delete(:visibilityData)
      content_type_enum = {
        aggregatedfulltext: 1,
        abstractandindex: 2,
        ebook: 3,
        ejournal: 4,
        print: 5,
        unknown: 6,
        onlinereference: 7
      }
      payload[:contentType] = content_type_enum[payload[:contentType]&.downcase&.to_sym] || 6

      rmapi(:put, "/vendors/#{vendor_id}/packages/#{package_id}", json: payload)

      status, body = rmapi(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
      Result.new(data: to_package(body), status: status)
    end
  end
```

There are a few ways to address this, and I'll extend this document if we settle on one.  It's probably worthy of a discussion first.


### Tests

Currently, our request tests primarily test partial updates.  Since the UI sends the entire resource, we need to be testing for that case.  Our tests could be optimized pretty dramatically if we do a little reorganization, and since the current suite doesn't _really_ reflect the reality of `ui-eholdings`'s consumption of the API it's entierely possible we're missing erroneous behavior
