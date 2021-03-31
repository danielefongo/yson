defmodule Yson.Json do
  @moduledoc false
  use Yson.Macro
  use Yson.Macro.{Arg, Interface, Map, Reference, Value}
  require Yson.Macro.Map

  @allowed_macros [:value, :reference, :map, :interface]
  @mapping %{map: :nested_map, interface: :nested_interface}

  defmacro __using__(_) do
    quote do
      require Yson.Json
      import Yson.Json
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    [resolver, description] = Module.get_attribute(module, :description)
    references = Module.get_attribute(module, :references)

    body =
      Enum.reduce(description, %{}, fn {module, value}, m ->
        module.describe(value, m, references)
      end)

    resolvers =
      Enum.reduce(description, %{}, fn {module, value}, m ->
        module.resolver(value, m, references)
      end)

    quote do
      def describe, do: unquote(Macro.escape(body))
      def resolvers, do: {unquote(resolver), unquote(Macro.escape(resolvers))}
    end
  end

  defmacro root(opts \\ [], do: body) do
    fields = fetch(body, @allowed_macros, @mapping)
    resolver = Keyword.get(opts, :resolver, &identity/1)

    quote do
      if :elixir_module.mode(__MODULE__) == :all do
        Module.put_attribute(__MODULE__, :description, [unquote(resolver), unquote(fields)])
      end

      unquote(fields)
    end
  end
end
