defmodule Graphy.ApiTest do
  use ExUnit.Case
  use TestApi
  alias Graphy.Api
  alias Support.{PersonClient, PersonServer}

  api_test "ask and parse using Graphy schema" do
    expected_result = %{sample: %{email: "a@b.c", user: %{full_name: "legal name"}}}
    variables = %{email: "a@b.c"}

    mock :post, "/graphql" do
      %{"query" => query, "variables" => variables} = json_body()
      {:ok, output} = Absinthe.run(query, PersonServer, variables: variables)
      assert not is_nil(output[:data]), Map.get(output, :errors, "Invalid GraphQL request")

      response(200, Jason.encode!(output))
    end

    {:ok, result} = Api.run(PersonClient, variables, "localhost:55000/graphql")

    assert result == expected_result
  end
end
