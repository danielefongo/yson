defmodule GraphqlBuilderTest do
  use ExUnit.Case

  describe "for inner query" do
    test "build empty" do
      assert GraphqlBuilder.build_body(%{}) == "{\n}"
    end

    test "build with root fields" do
      assert GraphqlBuilder.build_body(%{name: nil, surname: nil}) == "{\n  name\n  surname\n}"
    end

    test "build with nested fields" do
      assert GraphqlBuilder.build_body(%{root: %{nested: nil}}) ==
               "{\n  root {\n    nested\n  }\n}"
    end

    test "build with simple interfaces" do
      assert GraphqlBuilder.build_body(%{root: %{person: [name: nil]}}) ==
               "{\n  root {\n    ... on Person {\n      name\n    }\n  }\n}"
    end

    test "build with mixed fields and interfaces" do
      assert GraphqlBuilder.build_body(%{root: %{value: nil, person: [name: nil]}}) ==
               "{\n  root {\n    ... on Person {\n      name\n    }\n    value\n  }\n}"
    end

    test "build using camel case" do
      assert GraphqlBuilder.build_body(%{full_name: nil}) == "{\n  fullName\n}"
    end
  end

  describe "for query params" do
    test "build empty" do
      assert GraphqlBuilder.build_arguments(%{}) == "()"
    end

    test "build with root arguments" do
      assert GraphqlBuilder.build_arguments(%{first_name: :string, last_name: :string}) ==
               "(firstName: $firstName, lastName: $lastName)"
    end

    test "build with nested arguments" do
      assert GraphqlBuilder.build_arguments(%{user: %{first_name: :string, last_name: :string}}) ==
               "(user: {firstName: $firstName, lastName: $lastName})"
    end
  end
end
