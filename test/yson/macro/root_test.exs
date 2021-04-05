defmodule Yson.Macro.RootTest do
  use ExUnit.Case
  require Yson.Macro.{Root, Value}
  import Yson.Macro.{Root, Value}
  import Function, only: [identity: 1]

  alias Yson.Macro.Value

  test "root" do
    [resolver, [first_value, second_value]] =
      root do
        value(:foo)
        value(:bar)
      end

    assert resolver == (&identity/1)
    assert first_value == {Value, [:foo, &identity/1]}
    assert second_value == {Value, [:bar, &identity/1]}
  end
end
