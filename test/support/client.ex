defmodule Support.Client do
  @moduledoc false
  use Yson.GraphQL.Schema

  import_schema(Support.User)

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
