defmodule Graphy.GraphQL.ApiTest do
  use ExUnit.Case
  use TestApi
  alias Graphy.GraphQL.Api
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

  api_test "ask and parse errors" do
    variables = %{email: "a@b.c"}
    errors = ["error1", "error2"]

    mock :post, "/graphql" do
      response(200, Jason.encode!(graphql_errors(errors)))
    end

    {:error, errors} = Api.run(PersonClient, variables, "localhost:55000/graphql")

    assert errors == "error1, error2"
  end

  api_test "handle bad response code" do
    variables = %{email: "a@b.c"}

    mock :post, "/graphql" do
      response(400, "body")
    end

    {:error, errors} = Api.run(PersonClient, variables, "localhost:55000/graphql")

    assert errors == "bad response code 400: body"
  end

  test "handle http error" do
    opts = [timeout: 10, recv_timeout: 10]

    variables = %{email: "a@b.c"}

    {:error, errors} = Api.run(PersonClient, variables, "localhost:66000/graphql", [], opts)

    Process.sleep(100)

    assert errors == "HTTP error checkout_failure"
  end

  defp graphql_errors(messages) do
    errors =
      Enum.map(messages, fn message ->
        %{locations: [%{column: 10, line: 2}], message: message}
      end)

    %{errors: errors}
  end
end
