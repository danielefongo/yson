defmodule Yson.Macro.Reference do
  @moduledoc false
  use Yson.Macro

  defmacro __using__(_) do
    quote do
      alias Yson.Macro.Reference
      require Reference

      defmacro reference(reference), do: {Reference, [reference]}
    end
  end

  def describe([ref], map, references) do
    references
    |> Keyword.get(ref)
    |> apply_nested(:describe, references)
    |> Map.merge(map)
  end

  def resolver([ref], map, references) do
    references
    |> Keyword.get(ref)
    |> apply_nested(:resolver, references)
    |> Map.merge(map)
  end

  defp apply_nested({module, data}, fun, references) do
    apply(module, fun, [data, %{}, references])
  end
end
