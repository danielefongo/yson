defmodule Yson.Json.SchemaTest do
  use ExUnit.Case

  defmodule Sample do
    use Yson.Json.Schema

    root do
      value(:foo)
      value(:bar)
    end

    def root(data), do: data
  end

  test "generate description" do
    description = Sample.describe()

    assert description == [:foo, :bar]
  end

  test "generate resolvers" do
    assert {_, [foo: _, bar: _]} = Sample.resolvers()
  end
end
