defmodule GraphqlBuilderTest do
  use ExUnit.Case

  describe "for inner body" do
    test "build empty" do
      assert GraphqlBuilder.build(description(:people, %{}, %{})) =~ "{\n  }"
    end

    test "build with root fields" do
      assert GraphqlBuilder.build(description(:people, %{}, %{name: nil, surname: nil})) =~
               "{\n    name\n    surname\n  }"
    end

    test "build with nested fields" do
      assert GraphqlBuilder.build(description(:people, %{}, %{root: %{nested: nil}})) =~
               "{\n    root {\n      nested\n    }\n  }"
    end

    test "build with simple interfaces" do
      assert GraphqlBuilder.build(description(:people, %{}, %{root: %{person: [name: nil]}})) =~
               "{\n    root {\n      ... on Person {\n        name\n      }\n    }\n  }"
    end

    test "build with mixed fields and interfaces" do
      assert GraphqlBuilder.build(
               description(:people, %{}, %{root: %{value: nil, person: [name: nil]}})
             ) =~
               "{\n    root {\n      ... on Person {\n        name\n      }\n      value\n    }\n  }"
    end

    test "build using camel case" do
      assert GraphqlBuilder.build(description(:people, %{}, %{full_name: nil})) =~
               "{\n    fullName\n  }"
    end
  end

  describe "for query params" do
    test "build empty" do
      assert GraphqlBuilder.build(description(:people, %{}, %{})) =~ "people {"
    end

    test "build with root arguments" do
      assert GraphqlBuilder.build(
               description(:people, %{first_name: :string, last_name: :string}, %{})
             ) =~
               "people(firstName: $firstName, lastName: $lastName) {"
    end

    test "build with nested arguments" do
      assert GraphqlBuilder.build(
               description(
                 :people,
                 %{
                   user: %{first_name: :string, last_name: :string}
                 },
                 %{}
               )
             ) =~
               "people(user: {firstName: $firstName, lastName: $lastName}) {"
    end
  end

  describe "for query" do
    test "build empty" do
      assert GraphqlBuilder.build(description(:people, %{}, %{})) =~ "query {"
    end

    test "build with root arguments" do
      assert GraphqlBuilder.build(
               description(:people, %{first_name: :string, age: :integer}, %{})
             ) =~
               "query ($age: Integer, $firstName: String) {"
    end

    test "build with nested arguments" do
      assert GraphqlBuilder.build(
               description(
                 :people,
                 %{foo: :integer, user: %{first_name: :string}},
                 %{}
               )
             ) =~
               "query ($foo: Integer, $firstName: String) {"
    end
  end

  defp description(object, args, body) do
    %{
      kind: :query,
      object: object,
      arguments: args,
      body: body
    }
  end
end
