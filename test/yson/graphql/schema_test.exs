defmodule Yson.GraphQL.SchemaTest do
  use ExUnit.Case

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

      assert description.body == [sample: [:email, :age]]

      assert description.arguments == %{data: :string, user: %{email: :string, age: :integer}}
    end

    test "generate resolvers" do
      assert [sample: {_, [email: _, age: _]}] = SampleQuery.resolvers()
    end
  end

  describe "mutation" do
    test "generate description" do
      description = SampleMutation.describe()

      assert description.object == :sample

      assert description.body == [sample: [:email, :age]]

      assert description.arguments == %{data: :string, user: %{email: :string, age: :integer}}
    end

    test "generate resolvers" do
      assert [sample: {_, [email: _, age: _]}] = SampleMutation.resolvers()
    end
  end

  describe "check" do
    test "missing query" do
      assert_raise RuntimeError, fn ->
        defmodule MissingQuery do
          use Yson.GraphQL.Schema

          root do
            value(:foo)
          end
        end
      end
    end

    test "missing root" do
      assert_raise RuntimeError, fn ->
        defmodule MissingRoot do
          use Yson.GraphQL.Schema

          query :sample do
            arg(:foo, :string)
          end
        end
      end
    end
  end
end
