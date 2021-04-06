defmodule Yson.Macro.Reference do
  @moduledoc false
  alias __MODULE__
  alias Yson.Util.Attributes

  defmacro reference(reference), do: {Reference, [reference]}

  def set_references(module, data), do: Attributes.set(module, :references, data)
  def get_references(module), do: Attributes.get(module, :references)

  def set_reference(module, name, data), do: Attributes.set(module, :references, name, data)
  def get_reference(module, name), do: Attributes.get(module, :references, name)

  def describe([ref], map, module) do
    module
    |> get_reference(ref)
    |> apply_nested(:describe, module)
    |> Map.merge(map)
  end

  def resolver([ref], map, module) do
    module
    |> get_reference(ref)
    |> apply_nested(:resolver, module)
    |> Map.merge(map)
  end

  defp apply_nested({macro, data}, fun, module) do
    apply(macro, fun, [data, %{}, module])
  end
end
