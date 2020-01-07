# mod-kb-ebsco

[![Build Status](https://travis-ci.org/folio-org/mod-kb-ebsco.svg?branch=master)](https://travis-ci.org/folio-org/mod-kb-ebsco)

## License

Copyright (C) 2017-2018 [The Open Library Foundation][1]

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

[1]: http://www.openlibraryfoundation.org/

## Introduction

Module to broker communication with the EBSCO knowledge base.

## Setup

- Ruby 2.4.2
- rspec (test runner)

Environment variables needed:
- N/A

## Running tests

Run existing tests using

- bundle exec rspec

However, if new recordings for tests need to be made, set the following in .env file at the root of the project:

- TEST_CUSTOMER_ID
- TEST_API_KEY
- TEST_OKAPI_TOKEN
- TEST_RMAPI_URL

To run tests that also generate a code coverage report at `/coverage`

- COVERAGE=true bundle exec rspec

## Additional information

### Other documentation

Other [modules](https://dev.folio.org/source-code/#server-side) are described,
with further FOLIO Developer documentation at [dev.folio.org](https://dev.folio.org/)

### Issue tracker

See project [FOLIO](https://issues.folio.org/browse/FOLIO)
at the [FOLIO issue tracker](https://dev.folio.org/guidelines/issue-tracker).

