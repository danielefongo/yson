defmodule Yson.GraphQL.Api do
  @moduledoc """
  Defines the GraphQL Api.

  It also provides a function to run requests to the api and parse the obtained response,
  hiding the complexity of `Yson.GraphQL.Builder` and `Yson.Parser` usage

      iex> variables = %{var1: "value"}
      iex> headers = [] # optional
      iex> options = [] # optional
      iex> Api.run(Schema, variables, "https://mysite.com/graphql", headers, options)
  """
  alias Yson.GraphQL.Builder
  alias Yson.Parser

  @doc """
  Executes the GraphQL request and returns the parsed response or an error.

  ### Example
      run(ASchema, %{var1: "value"})

  A successful call will return `{:ok, parsed_data}`, while a failed call will return a generic error `{:error, message}`.
  """
  def run(schema, vars, graphql_url, headers \\ [], options \\ []) do
    body =
      schema.describe()
      |> Builder.build(vars)
      |> Jason.encode!()

    graphql_url
    |> HTTPoison.post(body, headers, options)
    |> response()
    |> parse_response(schema.resolvers())
  end

  defp response({:ok, %HTTPoison.Response{status_code: 200, body: body_string}}) do
    Jason.decode(body_string, keys: :atoms)
  end

  defp response({:ok, %HTTPoison.Response{status_code: code, body: body}}) do
    {:error, "bad response code #{code}: #{body}"}
  end

  defp response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "HTTP error #{reason}"}
  end

  defp parse_response({:error, error}, _) when is_binary(error), do: {:error, error}

  defp parse_response({:ok, %{errors: errors}}, _) do
    errors =
      errors
      |> Enum.map(& &1.message)
      |> Enum.join(", ")

    {:error, errors}
  end

  defp parse_response({:ok, %{data: data}}, resolvers) do
    {:ok, Parser.parse(resolvers, data, :snake)}
  end
end
