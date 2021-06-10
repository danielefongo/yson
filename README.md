# Yson

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/danielefongo/yson/ci)
![Coveralls](https://img.shields.io/coveralls/github/danielefongo/yson)
[![Hex pm](http://img.shields.io/hexpm/v/yson.svg?style=flat)](https://hex.pm/packages/yson)
![Hex.pm](https://img.shields.io/hexpm/l/yson)

Run json/graphql requests and parse responses in an easy way.

## Installation

The package can be installed by adding `yson` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yson, "~> 0.2.0"}
  ]
end
```

## Usage

`yson` can be used both to run GraphQL requests and to parse JSON responses.

### GraphQL

First create a `Yson.GraphQL.Schema` object:

```elixir
defmodule User do
  use Yson.GraphQL.Schema

  query :user do # defines a query on :user
    arg :person do
      arg(:full_name, :string)
    end
  end

  root do
    value(:email)

    map :person, resolver: &User.person/1 do
      interface :natural_person do
        value(:first_name)
        value(:last_name)
      end

      interface :legal_person do
        value(:company_name)
      end
    end
  end

  def person(%{company_name: name}), do: %{full_name: name}
  def person(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
```

Then run a Graphql request using `Yson.GraphQL.Api`:

```elixir
alias Yson.GraphQL.Api

variables = %{full_name: "john doe"}
headers = [] #optional
options = [] #optional
{:ok, result} = Api.run(User, variables, "https://mysite.com/graphql", headers, options)
```

The result will be already mapped using resolvers, so it could be something like the following:

```elixir
%{
  user: %{
    email: "a@b.c",
    person: %{
      full_name: "legal name"
    }
  }
}
```

#### Custom usage

The `Yson.GraphQL.Schema` object exposes two methods:

- `&describe/0`, to build the object description.
- `&resolvers/0`, to build the object resolvers tree.

that can be combined with the modules `Yson.GraphQL.Builder` and `Yson.Parser`.

##### Create query

`Yson.GraphQL.Builder.build/2` accepts a Yson description and the variables. It can be used as follows:

```elixir
iex> Yson.GraphQL.Builder.build(User.describe(), variables)
iex> %{
  query: "query ($fullName: String) {\n  user(person: {fullName: $fullName}) {\n    email\n    person {\n      ... on LegalPerson {\n        companyName\n      }\n      ... on NaturalPerson {\n        firstName\n        lastName\n      }\n    }\n  }\n}",
  variables: %{full_name: "john doe"}
}
```

##### Parse response

`Yson.Parser.parse/3` accepts a Yson resolvers tree and the payload (map with atom keys). It can be used as follows:

```elixir
iex> payload = %{user: %{email: "a@b.c", person: %{companyName: "legal name"}}}
iex> Yson.Parser.parse(User.resolvers(), payload, :snake)
iex> %{
  user: %{
    email: "a@b.c",
    user: %{
      full_name: "legal name"
    }
  }
}
```

### JSON

Currently there is no implemented `Api` module for running Json requests, but it is still possible to use `yson` to parse responses.

#### Define schema

The first step is to define a `Yson.Json.Schema` schema.

```elixir
defmodule User do
  use Yson.Json.Schema

  root do # defines the object root
    value(:email)

    map :person, resolver: &User.person/1 do
      interface :natural_person do
        value(:first_name)
        value(:last_name)
      end

      interface :legal_person do
        value(:company_name)
      end
    end
  end

  def person(%{company_name: name}), do: %{full_name: name}
  def person(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
```

#### Parse response

`Yson.Parser.parse/3` accepts a Yson resolvers tree and the payload (map with atom keys). It can be used as follows:

```elixir
iex> payload = %{email: "a@b.c", person: %{companyName: "legal name"}}
iex> Yson.Parser.parse(User.resolvers(), payload, :snake)
iex> %{email: "a@b.c", user: %{full_name: "legal name"}}
```

The available strategies for key recasing are:

- `:snake` to convert payload keys to snake case before parsing
- `:camel` to convert payload keys to camel case before parsing
- `:no_case` to preserve the original casing
