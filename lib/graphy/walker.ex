defmodule Graphy.Walker do
  @moduledoc false
  import Enum
  import Recase

  def walk(resolvers, data) when is_map(resolvers) and is_map(data) do
    data
    |> map(fn {key, val} -> {to_snake(key), resolvers |> Map.get(to_snake(key)) |> walk(val)} end)
    |> filter(fn {_, val} -> not is_nil(val) end)
    |> into(%{})
  end

  def walk({resolver, resolvers}, data) when is_map(data) do
    data
    |> map(fn {key, val} -> {to_snake(key), resolvers |> Map.get(to_snake(key)) |> walk(val)} end)
    |> filter(fn {_, val} -> not is_nil(val) end)
    |> into(%{})
    |> resolver.()
  end

  def walk(resolver, data) when is_list(data), do: map(data, fn val -> walk(resolver, val) end)

  def walk(resolver, data), do: resolver.(data)
end
