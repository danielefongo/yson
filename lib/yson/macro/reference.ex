defmodule Yson.Macro.Reference do
  @moduledoc false
  alias __MODULE__
  alias Yson.Util.Attributes

  defmacro reference(reference), do: {Reference, [reference]}

  def set_reference(module, name, data) do
    quote do
      Attributes.set(unquote(module), :references, unquote(name), unquote(data))
    end
  end

  def describe([ref], map, module) do
    module
    |> Attributes.get(:references, ref)
    |> apply_nested(:describe, module)
    |> Map.merge(map)
  end

  def resolver([ref], map, module) do
    module
    |> Attributes.get(:references, ref)
    |> apply_nested(:resolver, module)
    |> Map.merge(map)
  end

  defp apply_nested({macro, data}, fun, module) do
    apply(macro, fun, [data, %{}, module])
  end
end
