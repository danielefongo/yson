defmodule GraphqlBuilderTest do
  use ExUnit.Case

  test "build empty inner query" do
    assert GraphqlBuilder.build(%{}) == "{\n}"
  end

  test "build query with root fields" do
    assert GraphqlBuilder.build(%{name: nil, surname: nil}) == "{\n  name\n  surname\n}"
  end

  test "build query with nested fields" do
    assert GraphqlBuilder.build(%{root: %{nested: nil}}) == "{\n  root {\n    nested\n  }\n}"
  end

  test "build query using camel case" do
    assert GraphqlBuilder.build(%{full_name: nil}) == "{\n  fullName\n}"
  end

  test "build query using struct" do
    assert GraphqlBuilder.build(%Example{}) == "{\n  age\n  name\n  phone\n}"
  end
end
