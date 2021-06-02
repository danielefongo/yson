defmodule Yson.Util.ASTTest do
  use ExUnit.Case
  alias Yson.Util.AST

  test "map single inner element" do
    body =
      quote do
        value(:field)
      end

    assert AST.fetch(body, [:value]) == [{:value, [], [:field]}]
  end

  test "map multiple inner elements" do
    body =
      quote do
        value(:field)
        value(:field2)
      end

    assert AST.fetch(body, [:value]) == [{:value, [], [:field]}, {:value, [], [:field2]}]
  end

  test "raise on invalid markers" do
    body =
      quote do
        value(:field)
      end

    assert_raise RuntimeError, fn ->
      AST.fetch(body, [])
    end
  end

  test "remap markers" do
    body =
      quote do
        value(:field)
      end

    assert AST.fetch(body, [:value], %{value: :reference}) == [{:reference, [], [:field]}]
  end
end
