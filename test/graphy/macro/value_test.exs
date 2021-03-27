defmodule Graphy.Macro.ValueTest do
  use ExUnit.Case
  use Graphy.Macro.Value

  def echo_resolver(e), do: e

  describe "on macro" do
    test "value returns valid payload with default resolver" do
      {module, data} = value(:foo)

      assert module == Value
      assert data == [:foo, &Function.identity/1]
    end

    test "value returns valid payload with custom resolver" do
      {module, data} = value(:foo, &echo_resolver/1)

      assert module == Value
      assert data == [:foo, &echo_resolver/1]
    end
  end
end
