# Yson

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/danielefongo/yson/ci)
![Coveralls](https://img.shields.io/coveralls/github/danielefongo/yson)
![GitHub](https://img.shields.io/github/license/danielefongo/yson)

Run graphql requests and parse responses in an easy way.

## Installation

The package can be installed by adding `yson` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yson, git: "https://github.com/danielefongo/yson.git"}
  ]
end
```

## Usage

First create a `Yson` object:

``` elixir
defmodule Person do
  use Yson

  query :person do # defines a query on map :person
    arg :user do
      arg(:fiscal_id, :string)
    end
  end

  map :person do
    value(:email)

    map :user, resolver: &Person.user/1 do
      interface :natural_person do
        value(:first_name)
        value(:last_name)
      end

      ref(:legal_person, :legal_person)

      resolver()
    end
  end

  interface :legal_person do
    value(:company_name)
  end

  def user(%{company_name: name}), do: %{full_name: name}
  def user(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
```

Then do a request to your graphql endpoint using `Yson.Api`:

```elixir
alias Yson.Api

variables = %{fiscal_id: "01234"}
headers = [] #optional
options = [] #optional
{:ok, result} = Api.run(Person, variables, "https://mysite.com/graphql", headers, options)
```

The result will be already mapped using resolvers, so it could be something like the following:

```elixir
%{
  person: %{
    email: "a@b.c",
    user: %{
      full_name: "legal name"
    }
  }
}
```

## Custom usage

The `Yson` object exposes two methods:
- `&describe/0`, to build the object description.
- `&resolvers/0`, to build the object resolvers tree.

that can be combined with the modules `Yson.Builder` and `Yson.Parser`.

### Create query

`&Yson.Builder.build/2` accepts a Yson description and the variables. A usage can be the following:
```elixir
iex> Yson.Builder.build(Person.describe(), variables)
iex> %{
  query: "query ($fiscalId: String) {\n  person(user: {fiscalId: $fiscalId}) {\n    email\n    user {\n      ... on LegalPerson {\n        companyName\n      }\n      ... on NaturalPerson {\n        firstName\n        lastName\n      }\n    }\n  }\n}",
  variables: %{fiscal_id: "01234"}
}
```

### Parse response
`&Yson.Parser.parse/2` accepts a Yson resolvers tree and the payload (map with atom keys). A usage can be the following:
```elixir
iex> Yson.Parser.parse(Person.resolvers(), payload)
iex> %{
  person: %{
    email: "a@b.c",
    user: %{
      full_name: "legal name"
    }
  }
}
```