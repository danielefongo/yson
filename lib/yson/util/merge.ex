defmodule Yson.Util.Merge do
  @moduledoc false

  def merge(nil, data), do: data
  def merge(data, nil), do: data

  def merge(first, second) when is_map(first) and is_map(second) do
    check_conflicts(Map.keys(first), Map.keys(second))
    Map.merge(first, second)
  end

  def merge(first, second) when is_list(first) and is_list(second) do
    case {Keyword.keyword?(first), Keyword.keyword?(second)} do
      {true, true} ->
        check_conflicts(Keyword.keys(first), Keyword.keys(second))
        Keyword.merge(first, second)

      {false, false} ->
        check_conflicts(first, second)
        Enum.concat(first, second)

      _ ->
        first
    end
  end

  def merge(first, _), do: first

  defp check_conflicts(keys1, keys2) do
    conflicts = Enum.filter(keys1, fn key -> Enum.member?(keys2, key) end)

    if conflicts != [] do
      raise "Found conflicts: #{inspect(conflicts)}"
    end
  end
end
