defmodule Yson.Macro.QueryTest do
  use ExUnit.Case
  require Yson.Macro.{Query, Arg}
  import Yson.Macro.{Query, Arg}

  test "query" do
    obj =
      query :sample do
        arg(:one, :string)
        arg(:two, :integer)
      end

    assert obj == %{one: :string, two: :integer}
  end

  test "mutation" do
    obj =
      mutation :sample do
        arg(:one, :string)
        arg(:two, :integer)
      end

    assert obj == %{one: :string, two: :integer}
  end
end
