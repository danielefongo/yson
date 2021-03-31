defmodule Yson.Parser do
  @moduledoc false
  import Enum
  import Recase

  def parse(resolvers, data) when is_map(resolvers) and is_map(data) do
    parse_nested_data(resolvers, data)
  end

  def parse({resolver, resolvers}, data) when is_map(data) do
    resolvers
    |> parse_nested_data(data)
    |> resolver.()
  end

  def parse(resolver, data) when is_list(data), do: map(data, &parse(resolver, &1))

  def parse(resolver, data), do: resolver.(data)

  def parse_nested_data(resolvers, data) do
    data
    |> filter(fn {key, _} -> not is_nil(Map.get(resolvers, to_snake(key))) end)
    |> map(fn {key, val} -> {to_snake(key), resolvers |> Map.get(to_snake(key)) |> parse(val)} end)
    |> into(%{})
  end
end
