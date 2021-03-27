defmodule Graphy.Macro.RefTest do
  use ExUnit.Case
  use Graphy.Macro.Ref

  describe "on macro" do
    test "reference returns valid payload" do
      {module, data} = ref(:foo, :another)

      assert module == Ref
      assert data == [:foo, :another]
    end
  end
end
