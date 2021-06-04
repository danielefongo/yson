defmodule Support.Client do
  @moduledoc false
  use Yson.GraphQL.Schema

  import_schema(Support.Person)

  query :user do
    arg :input do
      arg(:email, :string)
    end
  end

  root do
    value(:email)
    reference(:my_person, as: :person)
  end
end
