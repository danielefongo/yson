# Graphy

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/danielefongo/graphy/ci)
![Coveralls](https://img.shields.io/coveralls/github/danielefongo/graphy)
![GitHub](https://img.shields.io/github/license/danielefongo/graphy)

Run graphql requests and parse responses in an easy way.

## Installation

The package can be installed by adding `graphy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:graphy, git: "https://github.com/danielefongo/graphy.git"}
  ]
end
```

## Usage

First create a `Graphy` object:

``` elixir
defmodule Person do
  use Graphy

  query do # runs a query
    arg :user do
      arg(:fiscal_id, :string)
    end
  end

  object :person do # defines the graphql schema to be queried for
    field(:email)

    field :user do
      interface :natural_person do
        field(:first_name)
        field(:last_name)
      end

      interface :legal_person do
        field(:company_name)
      end

      resolver(&Person.user/1)
    end
  end

  def user(%{company_name: name}), do: %{full_name: name}
  def user(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
```

Then do a request to your graphql endpoint using `Graphy.Api`:

```elixir
alias Graphy.Api

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

The `Graphy` object exposes two methods:
- `&describe/0`, to build the object description.
- `&resolvers/0`, to build the object resolvers tree.

that can be combined with the modules `Graphy.Builder` and `Graphy.Walker`.

### Create query

`&Graphy.Builder.build/2` accepts a Graphy description and the variables. A usage can be the following:
```elixir
iex> Graphy.Builder.build(Person.describe(), variables)
iex> %{
  query: "query ($fiscalId: String) {\n  person(user: {fiscalId: $fiscalId}) {\n    email\n    user {\n      ... on LegalPerson {\n        companyName\n      }\n      ... on NaturalPerson {\n        firstName\n        lastName\n      }\n    }\n  }\n}",
  variables: %{fiscal_id: "01234"}
}
```

### Parse response
`&Graphy.Walker.walk/2` accepts a Graphy resolvers tree and the payload (map with atom keys). A usage can be the following:
```elixir
iex> Graphy.Walker.walk(Person.resolvers(), payload)
iex> %{
  person: %{
    email: "a@b.c",
    user: %{
      full_name: "legal name"
    }
  }
}
```