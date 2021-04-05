defmodule Yson.Macro.ArgTest do
  use ExUnit.Case
  require Yson.Macro.Arg
  import Yson.Macro.Arg

  test "single argument" do
    data = arg(:foo, :string)

    assert data == {:foo, :string}
  end

  test "composite argument" do
    data =
      arg :foo do
        arg(:foo, :string)
      end

    assert data == {:foo, %{foo: :string}}
  end
end
