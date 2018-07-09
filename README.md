# mod-kb-ebsco

[![Build Status](https://travis-ci.org/folio-org/mod-kb-ebsco.svg?branch=master)](https://travis-ci.org/folio-org/mod-kb-ebsco)

## License

Copyright (C) 2017-2018 [The Open Library Foundation][1]

This software is distributed under the terms of the Apache License, Version 2.0. See the file "LICENSE" for more information.

[1]: http://www.openlibraryfoundation.org/

## Introduction

Module to broker communication with the EBSCO knowledge base.

## Setup

- Ruby 2.4.2
- rspec (test runner)

Environment variables needed:
- `EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL`
- `EBSCO_RESOURCE_MANAGEMENT_API_CUSTOMER_ID`
- `EBSCO_RESOURCE_MANAGEMENT_API_KEY`

Place in `.env` or CI project settings.

## Running tests

Run existing tests using

- bundle exec rspec

However, if new recordings for tests need to be made, set the following in .env file at the root of the project:

- TEST_CUSTOMER_ID
- TEST_API_KEY
- TEST_OKAPI_TOKEN

To run tests that also generate a code coverage report at `/coverage`

- COVERAGE=true bundle exec rspec

## Additional information

Other [modules](https://dev.folio.org/source-code/#server-side).

Other FOLIO Developer documentation is at [dev.folio.org](https://dev.folio.org/)
