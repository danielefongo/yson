defmodule Graphy.Util.IndentTest do
  use ExUnit.Case
  alias Graphy.Util.Indent

  test "indent flat" do
    assert Indent.indent(["a", "b"]) == "a\nb"
  end

  test "indent nested" do
    assert Indent.indent(["a", ["b"]]) == "a\n  b"
  end

  test "indent using custom initial indent" do
    assert Indent.indent(["a", "b"], 1) == "  a\n  b"
  end
end
