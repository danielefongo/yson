defmodule Yson.GraphQL.BuilderTest do
  use ExUnit.Case

  @object :people

  describe "for inner body" do
    test "build empty" do
      args = %{}
      vars = %{}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~ "{\n  }"
    end

    test "build with root fields" do
      args = %{}
      vars = %{}
      body = [people: [:name, :surname]]

      assert build_query(@object, args, body, vars).query =~ "{\n    name\n    surname\n  }"
    end

    test "build with nested fields" do
      args = %{}
      vars = %{}
      body = [people: [root: [:nested]]]

      assert build_query(@object, args, body, vars).query =~
               "{\n    root {\n      nested\n    }\n  }"
    end

    test "build with simple interfaces" do
      args = %{}
      vars = %{}
      body = [people: [root: [person: {[:name]}]]]

      assert build_query(@object, args, body, vars).query =~
               "{\n    root {\n      ... on Person {\n        name\n      }\n    }\n  }"
    end

    test "build with mixed fields and interfaces" do
      args = %{}
      vars = %{}
      body = [people: [root: [{:person, {[:name]}}, :value]]]

      assert build_query(@object, args, body, vars).query =~
               "{\n    root {\n      ... on Person {\n        name\n      }\n      value\n    }\n  }"
    end

    test "build using camel case" do
      args = %{}
      vars = %{}
      body = [people: [:full_name]]

      assert build_query(@object, args, body, vars).query =~ "{\n    fullName\n  }"
    end
  end

  describe "for query params" do
    test "build empty" do
      args = %{}
      vars = %{}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~ "people {"
    end

    test "build with root arguments" do
      args = %{first_name: :string, last_name: :string}
      vars = %{first_name: "John", last_name: "Doe"}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~
               "#{@object}(firstName: $firstName, lastName: $lastName) {"
    end

    test "build with nested arguments" do
      args = %{user: %{first_name: :string, last_name: :string}}
      vars = %{first_name: "John", last_name: "Doe"}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~
               "#{@object}(user: {firstName: $firstName, lastName: $lastName}) {"
    end
  end

  describe "for query" do
    test "build empty" do
      args = %{}
      vars = %{}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~ "query {"
    end

    test "build with root arguments" do
      args = %{first_name: :string, age: :integer}
      vars = %{age: 18, first_name: "John"}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~
               "query ($age: Integer, $firstName: String) {"
    end

    test "build with nested arguments" do
      args = %{foo: :integer, user: %{first_name: :string}}
      vars = %{foo: 18, first_name: "John"}
      body = [people: []]

      assert build_query(@object, args, body, vars).query =~
               "query ($foo: Integer, $firstName: String) {"
    end
  end

  describe "for mutation" do
    test "build empty" do
      args = %{}
      vars = %{}
      body = [people: []]

      assert build_mutation(@object, args, body, vars).query =~ "mutation {"
    end

    test "build with root arguments" do
      args = %{first_name: :string, age: :integer}
      vars = %{first_name: "John", age: 18}
      body = [people: []]

      assert build_mutation(@object, args, body, vars).query =~
               "mutation ($age: Integer, $firstName: String) {"
    end

    test "build with nested arguments" do
      args = %{foo: :integer, user: %{first_name: :string}}
      vars = %{foo: 18, first_name: "John"}
      body = [people: []]

      assert build_mutation(@object, args, body, vars).query =~
               "mutation ($foo: Integer, $firstName: String) {"
    end
  end

  describe "for arguments" do
    test "validate shallow arguments" do
      args = %{first_name: :string, age: :integer}
      vars = %{first_name: "John"}
      body = [people: []]

      assert_raise RuntimeError, fn -> build_query(@object, args, body, vars).query end
    end

    test "validate nested arguments" do
      args = %{user: %{first_name: :string, age: :integer}}
      vars = %{first_name: "John"}
      body = [people: []]

      assert_raise RuntimeError, fn -> build_query(@object, args, body, vars).query end
    end
  end

  describe "for variables" do
    test "return variables" do
      args = %{first_name: :string, age: :integer}
      vars = %{first_name: "John", age: 18}
      body = [people: []]

      assert build_query(@object, args, body, vars).variables == %{first_name: "John", age: 18}
    end

    test "return only needed variables" do
      args = %{first_name: :string}
      vars = %{first_name: "John", useless_field: "any"}
      body = [people: []]

      assert build_query(@object, args, body, vars).variables == %{first_name: "John"}
    end
  end

  defp build_query(object, args, body, vars), do: build(:query, object, args, body, vars)

  defp build_mutation(object, args, body, vars),
    do: build(:mutation, object, args, body, vars)

  defp build(kind, object, args, body, vars) do
    Yson.GraphQL.Builder.build(%{kind: kind, object: object, arguments: args, body: body}, vars)
  end
end
