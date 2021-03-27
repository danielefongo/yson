defmodule Yson.Macro do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      require Yson.Macro
      import Yson.Macro
      import Function, only: [identity: 1]
    end
  end

  def update_attributes(category, name, keywords, update \\ true) do
    quote do
      if :elixir_module.mode(__MODULE__) == :all and unquote(update) do
        data = Module.get_attribute(__MODULE__, unquote(category), [])
        data = Keyword.put(data, unquote(name), unquote(keywords))
        Module.put_attribute(__MODULE__, unquote(category), data)
      end

      unquote(keywords)
    end
  end

  def fetch(body, markers, rename_mapping \\ %{}) do
    body
    |> ast_to_list()
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

  defp transform(list, mapping),
    do:
      Enum.map(list, fn {marker, metadata, children} ->
        new_marker = Map.get(mapping, marker, marker)
        {new_marker, metadata, children}
      end)
end
