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

  test "raise error when there are conflicts" do
    assert_raise(RuntimeError, fn -> Merge.merge([:a], [:a]) end)
    assert_raise(RuntimeError, fn -> Merge.merge([a: 1], a: 1) end)
    assert_raise(RuntimeError, fn -> Merge.merge(%{a: 1}, %{a: 1}) end)
  end

  test "raise error when trying to merge keyword with a list" do
    assert_raise(RuntimeError, fn -> Merge.merge([a: 1], [:a]) end)
  end
end
