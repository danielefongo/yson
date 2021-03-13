defmodule Graphy.BuilderTest do
  use ExUnit.Case

  describe "for inner body" do
    test "build empty" do
      query = build_query(:people, %{}, %{})
      assert query =~ "{\n  }"
    end

    test "build with root fields" do
      query = build_query(:people, %{}, %{name: nil, surname: nil})
      assert query =~ "{\n    name\n    surname\n  }"
    end

    test "build with nested fields" do
      query = build_query(:people, %{}, %{root: %{nested: nil}})
      assert query =~ "{\n    root {\n      nested\n    }\n  }"
    end

    test "build with simple interfaces" do
      query = build_query(:people, %{}, %{root: %{person: [name: nil]}})
      assert query =~ "{\n    root {\n      ... on Person {\n        name\n      }\n    }\n  }"
    end

    test "build with mixed fields and interfaces" do
      query = build_query(:people, %{}, %{root: %{value: nil, person: [name: nil]}})

      assert query =~
               "{\n    root {\n      ... on Person {\n        name\n      }\n      value\n    }\n  }"
    end

    test "build using camel case" do
      query = build_query(:people, %{}, %{full_name: nil})
      assert query =~ "{\n    fullName\n  }"
    end
  end

  describe "for query params" do
    test "build empty" do
      query = build_query(:people, %{}, %{})
      assert query =~ "people {"
    end

    test "build with root arguments" do
      query = build_query(:people, %{first_name: :string, last_name: :string}, %{})
      assert query =~ "people(firstName: $firstName, lastName: $lastName) {"
    end

    test "build with nested arguments" do
      query = build_query(:people, %{user: %{first_name: :string, last_name: :string}}, %{})
      assert query =~ "people(user: {firstName: $firstName, lastName: $lastName}) {"
    end
  end

  describe "for query" do
    test "build empty" do
      query = build_query(:people, %{}, %{})
      assert query =~ "query {"
    end

    test "build with root arguments" do
      query = build_query(:people, %{first_name: :string, age: :integer}, %{})
      assert query =~ "query ($age: Integer, $firstName: String) {"
    end

    test "build with nested arguments" do
      query = build_query(:people, %{foo: :integer, user: %{first_name: :string}}, %{})
      assert query =~ "query ($foo: Integer, $firstName: String) {"
    end
  end

  describe "for mutation" do
    test "build empty" do
      mutation = build_mutation(:people, %{}, %{})
      assert mutation =~ "mutation {"
    end

    test "build with root arguments" do
      mutation = build_mutation(:people, %{first_name: :string, age: :integer}, %{})
      assert mutation =~ "mutation ($age: Integer, $firstName: String) {"
    end

    test "build with nested arguments" do
      mutation = build_mutation(:people, %{foo: :integer, user: %{first_name: :string}}, %{})
      assert mutation =~ "mutation ($foo: Integer, $firstName: String) {"
    end
  end

  defp build_query(object, args, body), do: build(:query, object, args, body)
  defp build_mutation(object, args, body), do: build(:mutation, object, args, body)

  defp build(kind, object, args, body) do
    Graphy.Builder.build(%{
      kind: kind,
      object: object,
      arguments: args,
      body: body
    })
  end
end
