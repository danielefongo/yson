defmodule GraphqlBuilderTest do
  use ExUnit.Case

  describe "for inner query" do
    test "build empty" do
      assert GraphqlBuilder.build_body(%{}) == "  {\n  }"
    end

    test "build with root fields" do
      assert GraphqlBuilder.build_body(%{name: nil, surname: nil}) ==
               "  {\n    name\n    surname\n  }"
    end

    test "build with nested fields" do
      assert GraphqlBuilder.build_body(%{root: %{nested: nil}}) ==
               "  {\n    root {\n      nested\n    }\n  }"
    end

    test "build with simple interfaces" do
      assert GraphqlBuilder.build_body(%{root: %{person: [name: nil]}}) ==
               "  {\n    root {\n      ... on Person {\n        name\n      }\n    }\n  }"
    end

    test "build with mixed fields and interfaces" do
      assert GraphqlBuilder.build_body(%{root: %{value: nil, person: [name: nil]}}) ==
               "  {\n    root {\n      ... on Person {\n        name\n      }\n      value\n    }\n  }"
    end

    test "build using camel case" do
      assert GraphqlBuilder.build_body(%{full_name: nil}) == "  {\n    fullName\n  }"
    end
  end

  describe "for query params" do
    test "build empty" do
      assert GraphqlBuilder.build_arguments(:people, %{}) == "people"
    end

    test "build with root arguments" do
      assert GraphqlBuilder.build_arguments(:people, %{first_name: :string, last_name: :string}) ==
               "people(firstName: $firstName, lastName: $lastName)"
    end

    test "build with nested arguments" do
      assert GraphqlBuilder.build_arguments(:people, %{
               user: %{first_name: :string, last_name: :string}
             }) ==
               "people(user: {firstName: $firstName, lastName: $lastName})"
    end
  end

  describe "for query" do
    test "build empty" do
      assert GraphqlBuilder.build_query(%{}) == "query"
    end

    test "build with root arguments" do
      assert GraphqlBuilder.build_query(%{first_name: :string, age: :integer}) ==
               "query ($age: Integer, $firstName: String)"
    end

    test "build with nested arguments" do
      assert GraphqlBuilder.build_query(%{foo: :integer, user: %{first_name: :string}}) ==
               "query ($foo: Integer, $firstName: String)"
    end
  end
end
