defmodule Yson.Util.AST do
  @moduledoc false

  def fetch(body, markers, rename_mapping \\ %{}) do
    body
    |> ast_to_list()
    |> validate(markers)
    |> find_valid_macros(markers)
    |> transform(rename_mapping)
  end

  defp ast_to_list(body) do
    case body do
      {:__block__, _, content} -> content
      content -> [content]
    end
  end

  defp find_valid_macros(list, allowed),
    do: Enum.filter(list, fn {marker, _, _} -> Enum.member?(allowed, marker) end)

  defp validate(list, allowed) do
    invalid_macros? = Enum.any?(list, fn {marker, _, _} -> not Enum.member?(allowed, marker) end)

    if invalid_macros?, do: raise("Only #{inspect(allowed)} macros are allowed.")

    list
  end

  defp transform(list, mapping),
    do:
      Enum.map(list, fn {marker, metadata, children} ->
        new_marker = Map.get(mapping, marker, marker)
        {new_marker, metadata, children}
      end)
end
