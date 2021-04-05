defmodule Yson.Macro.Map do
  @moduledoc false
  import Yson.Util.AST
  import Map
  alias Yson.Macro.{Map, Reference}

  @allowed_macros [:value, :reference, :map, :interface]
  @mapping %{map: :nested_map, interface: :nested_interface}

  defmacro map(name, opts \\ [], do: body) do
    module = __CALLER__.module
    fields = fetch(body, @allowed_macros, @mapping)
    resolver = Keyword.get(opts, :resolver, &Function.identity/1)

    node = {Map, [name, resolver, fields]}

    Reference.set_reference(module, name, node)
  end

  defmacro nested_map(name, opts \\ [], do: body) do
    fields = fetch(body, @allowed_macros, @mapping)
    resolver = Keyword.get(opts, :resolver, &Function.identity/1)

    {Map, [name, resolver, fields]}
  end

  def describe([name, _resolver, list], map, module) do
    inner_map =
      Enum.reduce(list, %{}, fn {macro, value}, m -> macro.describe(value, m, module) end)

    put(map, name, inner_map)
  end

  def resolver([name, resolver, list], map, module) do
    inner_resolvers =
      Enum.reduce(list, %{}, fn {macro, value}, m -> macro.resolver(value, m, module) end)

    put(map, name, {resolver, inner_resolvers})
  end
end
