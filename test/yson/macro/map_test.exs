defmodule Yson.Macro.MapTest do
  use ExUnit.Case
  alias Yson.Macro.{Map, Value}
  use Yson.Macro.Map
  use Yson.Macro.Value

  def echo_resolver(e), do: e

  describe "on macro" do
    test "map returns valid payload with default resolver" do
      {module, data} =
        map :foo do
          value(:foo)
          value(:foo2)
        end

      [name, resolver, _] = data

      assert module == Map
      assert name == :foo
      assert resolver == (&Function.identity/1)
    end

    test "nested map returns valid payload" do
      {module, data} =
        nested_map :foo do
          value(:foo)
          value(:foo2)
        end

      [name, resolver, _] = data

      assert module == Map
      assert name == :foo
      assert resolver == (&Function.identity/1)
    end

    test "map returns custom resolver on payload" do
      {_, data} =
        map :foo, resolver: &Support.Macro.echo_resolver/1 do
          value(:foo)
        end

      [_, resolver, _] = data

      assert resolver == (&Support.Macro.echo_resolver/1)
    end
  end

  test "map insert description to map" do
    value = {Value, [:foo, &Function.identity/1]}

    description =
      Map.describe([:a_map, &Support.Macro.echo_resolver/1, [value]], %{data: :any}, %{})

    assert description == %{data: :any, a_map: %{foo: nil}}
  end

  test "map insert its resolver and nested resolvers to map" do
    value = {Value, [:foo, &Function.identity/1]}

    resolver = Map.resolver([:a_map, &Support.Macro.echo_resolver/1, [value]], %{data: :any}, %{})

    assert resolver == %{
             data: :any,
             a_map: {&Support.Macro.echo_resolver/1, %{foo: &Function.identity/1}}
           }
  end
end
