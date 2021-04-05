defmodule Yson.Macro.InterfaceTest do
  use ExUnit.Case
  alias Yson.Macro.{Interface, Value}
  require Yson.Macro.{Interface, Value}
  import Yson.Macro.{Interface, Value}

  def echo_resolver(e), do: e

  describe "on macro" do
    test "interface returns valid payload" do
      {module, data} =
        interface :foo do
          value(:foo)
          value(:foo2)
        end

      [name, _] = data

      assert module == Interface
      assert name == :foo
    end

    test "nested interface returns valid payload" do
      {module, data} =
        nested_interface :foo do
          value(:foo)
          value(:foo2)
        end

      [name, _] = data

      assert module == Interface
      assert name == :foo
    end
  end

  test "interface insert description to map" do
    value = {Value, [:foo, &Function.identity/1]}

    description = Interface.describe([:interface, [value]], %{data: :any}, %{})

    assert description == %{data: :any, interface: [foo: nil]}
  end

  test "interface merges nested resolvers to map" do
    value = {Value, [:foo, &Function.identity/1]}

    resolver = Interface.resolver([:interface, [value]], %{data: :any}, %{})

    assert resolver == %{data: :any, foo: &Function.identity/1}
  end
end
