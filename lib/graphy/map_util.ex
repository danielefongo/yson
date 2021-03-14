defmodule Graphy.MapUtil do
  def subset(map, keys) do
    map
    |> Enum.filter(fn {key, _} -> Enum.member?(keys, key) end)
    |> Enum.into(%{})
  end

  def has_keys?(map, keys) do
    map_keys = Map.keys(map)
    Enum.all?(keys, fn key -> Enum.member?(map_keys, key) end)
  end

  def flatten(%{} = json) do
    json
    |> Map.to_list()
    |> to_flat_map(%{})
  end

  def to_flat_map([{_k, %{} = v} | t], acc), do: to_flat_map(Map.to_list(v), to_flat_map(t, acc))
  def to_flat_map([{k, v} | t], acc), do: to_flat_map(t, Map.put_new(acc, k, v))
  def to_flat_map([], acc), do: acc
end
