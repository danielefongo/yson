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

  defp find_valid_macros(list, allowed), do: Enum.filter(list, &validate_single(&1, allowed))

  defp validate(list, allowed) do
    if not Enum.all?(list, &validate_single(&1, allowed)) do
      raise("Only #{inspect(allowed)} macros are allowed.")
    end

    list
  end

  defp validate_single({marker, _, _}, allowed), do: Enum.member?(allowed, marker)
  defp validate_single(_, _), do: false

  defp transform(list, mapping),
    do:
      Enum.map(list, fn {marker, metadata, children} ->
        new_marker = Map.get(mapping, marker, marker)
        {new_marker, metadata, children}
      end)
end
