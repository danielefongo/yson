defmodule Yson.Json.SchemaTest do
  use ExUnit.Case
  import Function, only: [identity: 1]
  import Support.Macro

  defmodule Sample do
    use Yson.Json.Schema

    root resolver: &echo_resolver/1 do
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
    assert Sample.resolvers() == {&echo_resolver/1, [foo: &identity/1, bar: &identity/1]}
  end
end
