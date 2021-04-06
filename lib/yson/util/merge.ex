defmodule Yson.Util.Merge do
  @moduledoc false

  def merge(nil, data), do: data
  def merge(data, nil), do: data
  def merge(first, second) when is_map(first) and is_map(second), do: Map.merge(first, second)

  def merge(first, second) when is_list(first) and is_list(second) do
    case {Keyword.keyword?(first), Keyword.keyword?(second)} do
      {true, true} -> Keyword.merge(first, second)
      {false, false} -> Enum.concat(first, second)
      _ -> first
    end
  end

  def merge(first, _), do: first
end
