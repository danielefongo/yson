defmodule Graphy.Walker do
  @moduledoc false

  require Logger

  def walk(resolvers, data) do
    resolvers
    |> Enum.map(fn {key, _} = el -> inner_walk(el, data, [key]) end)
    |> Enum.filter(fn {_, value} -> not is_nil(value) end)
    |> Enum.into(%{})
  end

  defp inner_walk({field, {resolver, resolvers}}, data, path) do
    inner =
      resolvers
      |> Enum.map(fn {key, _} = el -> inner_walk(el, data, path ++ [key]) end)
      |> Enum.filter(fn {_, value} -> not is_nil(value) end)
      |> Enum.into(%{})

    {field, resolver.(inner)}
  end

  defp inner_walk({field, resolver}, data, path) do
    {field, resolver.(get_in(data, path))}
  end
end
