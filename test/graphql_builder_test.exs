defmodule GraphqlBuilderTest do
  use ExUnit.Case
  doctest GraphqlBuilder

  test "greets the world" do
    assert GraphqlBuilder.hello() == :world
  end
end
