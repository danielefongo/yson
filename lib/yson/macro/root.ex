defmodule Yson.Macro.Root do
  @moduledoc false
  import Yson.Util.AST
  alias Yson.Util.Attributes

  @allowed_macros [:value, :reference, :map, :interface]
  @mapping %{map: :nested_map, interface: :nested_interface}

  defmacro root(opts \\ [], do: body) do
    module = __CALLER__.module
    fields = fetch(body, @allowed_macros, @mapping)
    resolver = Keyword.get(opts, :resolver, &Function.identity/1)

    quote do
      Attributes.set(unquote(module), :description, [unquote(resolver), unquote(fields)])
    end
  end

  def describe(module) do
    [_, description] = Attributes.get(module, :description)

    Enum.reduce(description, %{}, fn {macro, value}, m -> macro.describe(value, m, module) end)
  end

  def resolvers(module) do
    [resolver, description] = Attributes.get(module, :description)

    resolvers =
      Enum.reduce(description, %{}, fn {macro, value}, m -> macro.resolver(value, m, module) end)

    {resolver, resolvers}
  end
end
