# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.0] - 2021-06-10

### Added

- resolvers: enable partial local references (like `&my_resolver/1`) and anonymous functions.

### Changed

- `Yson.Schema.reference/2`: additional `as` option to rename referenced field.

## [0.1.0] - 2021-06-02

### Added

- `Yson.GraphQL.Api`: simple graphql client
- `Yson.GraphQL.Builder`: graphql query builder
- `Yson.GraphQL.Schema`: graphql schema object
- `Yson.Json.Schema`: json schema object
- `Yson.Parser`: json/graphql response parser
- `Yson.Schema`: basic schema object

[unreleased]: https://github.com/danielefongo/yson/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/danielefongo/yson/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/danielefongo/yson/releases/tag/v0.1.0
