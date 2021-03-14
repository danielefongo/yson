defmodule Graphy.Api do
  @moduledoc false
  alias Graphy.{Builder, Walker}

  def run(schema, vars, graphql_url) do
    body =
      schema.describe()
      |> Builder.build(vars)
      |> Jason.encode!()

    graphql_url
    |> HTTPoison.post(body)
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

  defp parse_response({:ok, %{data: data}}, resolvers), do: {:ok, Walker.walk(resolvers, data)}
end