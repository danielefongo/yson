defmodule Yson.Macro.Interface do
  @moduledoc false
  import Yson.Util.AST
  alias Yson.Macro.{Interface, Reference}

  @allowed_macros [:value, :reference, :map, :interface]
  @mapping %{map: :nested_map, interface: :nested_interface}

  defmacro interface(name, _opts \\ [], do: body) do
    module = __CALLER__.module
    fields = fetch(body, @allowed_macros, @mapping)

    node = {Interface, [name, fields]}

    Reference.set_reference(module, name, node)
  end

  defmacro nested_interface(name, _opts \\ [], do: body) do
    fields = fetch(body, @allowed_macros, @mapping)

    {Interface, [name, fields]}
  end

  def describe([name, list], map, module) do
    inner_keywords =
      list
      |> Enum.reduce(%{}, fn {macro, value}, m -> macro.describe(value, m, module) end)
      |> Enum.to_list()

    Map.put(map, name, inner_keywords)
  end

  def resolver([_name, list], map, module) do
    list
    |> Enum.reduce(%{}, fn {macro, value}, m -> macro.resolver(value, m, module) end)
    |> Map.merge(map)
  end
end
