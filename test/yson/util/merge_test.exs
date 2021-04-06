defmodule Yson.Util.MergeTest do
  use ExUnit.Case
  alias Yson.Util.Merge

  test "merge maps" do
    assert Merge.merge(%{a: 1}, %{b: 2}) == %{a: 1, b: 2}
  end

  test "merge keywords" do
    assert Merge.merge([a: 1], b: 2) == [a: 1, b: 2]
  end

  test "concat lists" do
    assert Merge.merge([:a], [:b]) == [:a, :b]
  end

  test "replace" do
    assert Merge.merge(:new, :old) == :new
  end

  test "ignore nils" do
    assert Merge.merge(:a, nil) == :a
    assert Merge.merge(nil, :a) == :a
  end
end
