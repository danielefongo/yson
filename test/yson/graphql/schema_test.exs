defmodule Yson.GraphQL.SchemaTest do
  use ExUnit.Case
  import Function, only: [identity: 1]

  defmodule SampleQuery do
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

  defmodule SampleMutation do
    use Yson.GraphQL.Schema

    mutation :sample do
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

  describe "query" do
    test "generate description" do
      description = SampleQuery.describe()

      assert description.object == :sample

      assert description.body == %{sample: %{age: nil, email: nil}}

      assert description.arguments == %{data: :string, user: %{email: :string, age: :integer}}
    end

    test "generate resolvers" do
      assert SampleQuery.resolvers() == [
               sample: {&identity/1, [email: &identity/1, age: &identity/1]}
             ]
    end
  end

  describe "mutation" do
    test "generate description" do
      description = SampleMutation.describe()

      assert description.object == :sample

      assert description.body == %{sample: %{age: nil, email: nil}}

      assert description.arguments == %{data: :string, user: %{email: :string, age: :integer}}
    end

    test "generate resolvers" do
      assert SampleMutation.resolvers() == [
               sample: {&identity/1, [email: &identity/1, age: &identity/1]}
             ]
    end
  end
end
