defmodule Graphy.Macro.ReferenceTest do
  use ExUnit.Case
  alias Graphy.Macro.{Reference, Value}
  use Graphy.Macro.Reference
  use Graphy.Macro.Value

  describe "on macro" do
    test "reference returns valid payload" do
      {module, data} = reference(:another)

      assert module == Reference
      assert data == [:another]
    end
  end

  test "reference insert description to map" do
    references = [referred: {Value, [:foo, &Function.identity/1]}]

    description = Reference.describe([:referred], %{data: :any}, references)

    assert description == %{data: :any, foo: nil}
  end

  test "reference merges nested resolvers to map" do
    references = [referred: {Value, [:foo, &Function.identity/1]}]

    resolver = Reference.resolver([:referred], %{data: :any}, references)

    assert resolver == %{data: :any, foo: &Function.identity/1}
  end
end
