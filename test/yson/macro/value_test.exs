defmodule Yson.Macro.ValueTest do
  use ExUnit.Case
  alias Yson.Macro.Value
  use Yson.Macro.Value

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

  test "value insert description to map" do
    description = Value.describe([:foo, &Function.identity/1], %{data: :any}, [])

    assert description == %{data: :any, foo: nil}
  end

  test "value insert resolver to map" do
    resolver = Value.resolver([:foo, &Function.identity/1], %{data: :any}, [])

    assert resolver == %{data: :any, foo: &Function.identity/1}
  end
end
