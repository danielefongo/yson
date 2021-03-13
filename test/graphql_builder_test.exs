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

  test "build query with simple interfaces" do
    assert GraphqlBuilder.build(%{root: %{person: [name: nil]}}) ==
             "{\n  root {\n    ... on Person {\n      name\n    }\n  }\n}"
  end

  test "build query with mixed fields and interfaces" do
    assert GraphqlBuilder.build(%{root: %{value: nil, person: [name: nil]}}) ==
             "{\n  root {\n    ... on Person {\n      name\n    }\n    value\n  }\n}"
  end

  test "build query using camel case" do
    assert GraphqlBuilder.build(%{full_name: nil}) == "{\n  fullName\n}"
  end
end
