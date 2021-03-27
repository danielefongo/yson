defmodule Graphy.Macro.InterfaceTest do
  use ExUnit.Case
  use Graphy.Macro.Interface
  use Graphy.Macro.Value

  describe "on macro" do
    test "interface returns valid payload" do
      {module, data} =
        interface :foo do
          value(:foo)
          value(:foo2)
        end

      [nested, name, resolver, _] = data

      assert module == Interface
      assert nested == false
      assert name == :foo
      assert resolver == (&Function.identity/1)
    end

    test "nested interface returns valid payload" do
      {module, data} =
        nested_interface :foo do
          value(:foo)
          value(:foo2)
        end

      [nested, name, resolver, _] = data

      assert module == Interface
      assert nested == true
      assert name == :foo
      assert resolver == (&Function.identity/1)
    end
  end
end
