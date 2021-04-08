defmodule Yson.Schema.Json do
  @moduledoc false
  require Yson.Macro.Root

  defmacro __using__(_) do
    quote do
      use Yson.Schema

      require Yson.Macro.Root
      import Yson.Macro.Root

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    body = Yson.Macro.Root.describe(module)
    resolvers = Yson.Macro.Root.resolvers(module)

    quote do
      def describe, do: unquote(Macro.escape(body))
      def resolvers, do: unquote(Macro.escape(resolvers))
    end
  end
end
