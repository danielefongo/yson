defmodule Yson.Macro.Map do
  @moduledoc false
  use Yson.Macro

  defmacro __using__(_) do
    quote do
      use Yson.Macro
      alias Yson.Macro.Map
      require Map

      @allowed_macros [:value, :reference, :map, :interface]
      @mapping %{map: :nested_map, interface: :nested_interface}

      defmacro map(name, opts \\ [], do: body) do
        fields = fetch(body, @allowed_macros, @mapping)
        resolver = Keyword.get(opts, :resolver, &identity/1)

        node = quote do: {Map, [unquote(name), unquote(resolver), unquote(fields)]}

        update_attributes(:references, name, node)
      end

      defmacro nested_map(name, opts \\ [], do: body) do
        fields = fetch(body, @allowed_macros, @mapping)
        resolver = Keyword.get(opts, :resolver, &identity/1)

        {Map, [name, resolver, fields]}
      end
    end
  end

  def describe([name, _resolver, list], map, references) do
    inner_map =
      Enum.reduce(list, %{}, fn {module, value}, m -> module.describe(value, m, references) end)

    Map.put(map, name, inner_map)
  end

  def resolver([name, resolver, list], map, references) do
    inner_resolvers =
      Enum.reduce(list, %{}, fn {module, value}, m -> module.resolver(value, m, references) end)

    Map.put(map, name, {resolver, inner_resolvers})
  end
end
