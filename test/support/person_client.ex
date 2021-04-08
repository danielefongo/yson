defmodule Support.PersonClient do
  @moduledoc false
  use Yson.Schema.GraphQL

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
