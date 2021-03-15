defmodule Graphy.Parser do
  @moduledoc false
  import Enum
  import Recase

  def parse(resolvers, data) when is_map(resolvers) and is_map(data) do
    data
    |> map(fn {key, val} -> {to_snake(key), resolvers |> Map.get(to_snake(key)) |> parse(val)} end)
    |> into(%{})
  end

  def parse({resolver, resolvers}, data) when is_map(data) do
    data
    |> map(fn {key, val} -> {to_snake(key), resolvers |> Map.get(to_snake(key)) |> parse(val)} end)
    |> into(%{})
    |> resolver.()
  end

  def parse(resolver, data) when is_list(data), do: map(data, fn val -> parse(resolver, val) end)

  def parse(resolver, data), do: resolver.(data)
end
