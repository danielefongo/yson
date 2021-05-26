defmodule Yson.Parser do
  @moduledoc """
  Defines the Json/GraphQL response parser.

      iex> Yson.Parser.parse(ASchema.resolvers(), payload)
      iex> %{
        schema: %{
          some_data: []
        }
      }

  Response extra fields are ignored and missing fields are not mapped in parsed response.
  """
  import Enum
  import Recase

  @doc """
  Parses the response.

  The first parameter is a `Yson.GraphQL.Schema` resolvers tree, the second one is the response payload, the third one is an optional recasing option.

  ### Example
      parse(ASchema.resolvers(), %{responseData: "value"})

  The optional third parameter can be one of the following:
    - `:snake` converts payload keys to snake case before parsing
    - `:camel` converts payload keys to camel case before parsing
    - `:no_case` does not convert payload keys before parsing
  """
  def parse(resolvers, data, to_case \\ :no_case), do: inner_parse(resolvers, data, to_case)

  defp inner_parse(resolvers, data, to_case) when is_map(resolvers) and is_map(data) do
    inner_parse_nested_map(resolvers, data, to_case)
  end

  defp inner_parse({resolver, resolvers}, data, to_case) when is_map(data) do
    resolvers
    |> inner_parse_nested_map(data, to_case)
    |> resolver.()
  end

  defp inner_parse(resolver, data, to_case) when is_list(data) do
    map(data, &inner_parse(resolver, &1, to_case))
  end

  defp inner_parse(resolver, data, _to_case), do: resolver.(data)

  defp inner_parse_nested_map(resolvers, data, to_case) do
    data
    |> map(fn {key, val} -> {recase(key, to_case), val} end)
    |> filter(fn {key, _} -> not is_nil(Map.get(resolvers, key)) end)
    |> map(fn {key, val} -> {key, resolvers |> Map.get(key) |> inner_parse(val, to_case)} end)
    |> into(%{})
  end

  defp recase(value, to_case) do
    case to_case do
      :snake -> to_snake(value)
      :camel -> to_camel(value)
      :no_case -> value
      invalid_case -> raise "Invalid case: #{invalid_case}."
    end
  end
end
