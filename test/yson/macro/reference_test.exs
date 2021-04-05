defmodule Yson.Macro.ReferenceTest do
  use ExUnit.Case
  alias Yson.Macro.{Reference, Value}
  require Yson.Macro.Reference
  import Yson.Macro.Reference

  defmodule Sample do
    Module.register_attribute(__MODULE__, :references, persist: true)
    Module.put_attribute(__MODULE__, :references, referred: {Value, [:foo, &Function.identity/1]})
  end

  describe "on macro" do
    test "reference returns valid payload" do
      {module, data} = reference(:another)

      assert module == Reference
      assert data == [:another]
    end
  end

  test "reference insert description to map" do
    description = Reference.describe([:referred], %{data: :any}, Sample)

    assert description == %{data: :any, foo: nil}
  end

  test "reference merges nested resolvers to map" do
    resolver = Reference.resolver([:referred], %{data: :any}, Sample)

    assert resolver == %{data: :any, foo: &Function.identity/1}
  end
end
