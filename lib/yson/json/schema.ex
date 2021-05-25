defmodule Yson.Json.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Yson.Schema

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    body = Yson.Schema.describe(module)
    resolvers = Yson.Schema.resolvers(module)

    quote do
      def describe, do: unquote(Macro.escape(body))
      def resolvers, do: unquote(Macro.escape(resolvers))
    end
  end
end
