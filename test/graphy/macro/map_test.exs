defmodule Graphy.Macro.MapTest do
  use ExUnit.Case
  use Graphy.Macro.Map
  use Graphy.Macro.Value

  def echo_resolver(e), do: e

  describe "on macro" do
    test "map returns valid payload with default resolver" do
      {module, data} =
        map :foo do
          value(:foo)
          value(:foo2)
        end

      [nested, name, resolver, _] = data

      assert module == Map
      assert nested == false
      assert name == :foo
      assert resolver == (&Function.identity/1)
    end

    test "nested map returns valid payload" do
      {module, data} =
        nested_map :foo do
          value(:foo)
          value(:foo2)
        end

      [nested, name, resolver, _] = data

      assert module == Map
      assert nested == true
      assert name == :foo
      assert resolver == (&Function.identity/1)
    end

    test "map returns custom resolver on payload" do
      {_, data} =
        map :foo, resolver: &echo_resolver/1 do
          value(:foo)
        end

      [_, _, resolver, _] = data

      assert resolver == (&echo_resolver/1)
    end
  end
end
