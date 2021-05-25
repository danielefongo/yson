defmodule Yson.GraphQL.SchemaTest do
  use ExUnit.Case
  import Function, only: [identity: 1]

  defmodule Sample do
    use Yson.GraphQL.Schema

    query :sample do
      arg(:data, :string)

      arg :user do
        arg(:email, :string)
        arg(:age, :integer)
      end
    end

    root do
      value(:email)
      value(:age)
    end
  end

  test "generate description" do
    description = Sample.describe()

    assert description.object == :sample

    assert description.body == %{sample: %{age: nil, email: nil}}

    assert description.arguments == %{data: :string, user: %{email: :string, age: :integer}}
  end

  test "generate resolvers" do
    assert Sample.resolvers() == %{sample: {&identity/1, %{age: &identity/1, email: &identity/1}}}
  end
end
