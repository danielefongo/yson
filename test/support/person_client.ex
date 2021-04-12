defmodule Support.PersonClient do
  @moduledoc false
  use Yson.GraphQL.Schema

  import_schema(Support.PersonSchema)

  query :sample do
    arg :user do
      arg(:email, :string)
    end
  end

  root do
    value(:email)
    reference(:user)
  end
end
