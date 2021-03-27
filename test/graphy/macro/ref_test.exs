defmodule Graphy.Macro.RefTest do
  use ExUnit.Case
  alias Graphy.Macro.{Ref, Value}
  use Graphy.Macro.Ref
  use Graphy.Macro.Value

  describe "on macro" do
    test "reference returns valid payload" do
      {module, data} = ref(:another)

      assert module == Ref
      assert data == [:another]
    end
  end

  test "reference insert description to map" do
    references = [referred: {Value, [:foo, &Function.identity/1]}]

    description = Ref.describe([:referred], %{data: :any}, references)

    assert description == %{data: :any, foo: nil}
  end

  test "reference merges nested resolvers to map" do
    references = [referred: {Value, [:foo, &Function.identity/1]}]

    resolver = Ref.resolver([:referred], %{data: :any}, references)

    assert resolver == %{data: :any, foo: &Function.identity/1}
  end
end
