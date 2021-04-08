defmodule Yson.Schema.GraphQL do
  @moduledoc false
  require Yson.Macro.Root
  require Yson.Macro.Query

  defmacro __using__(_) do
    quote do
      use Yson.Schema

      require Yson.Macro.{Query, Root}
      import Yson.Macro.{Query, Root}

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    object = Yson.Macro.Query.object(module)
    kind = Yson.Macro.Query.kind(module)
    arguments = Yson.Macro.Query.arguments(module)

    body = Map.put(%{}, object, Yson.Macro.Root.describe(module))
    resolvers = Map.put(%{}, object, Yson.Macro.Root.resolvers(module))

    quote do
      def describe,
        do: %{
          object: unquote(object),
          kind: unquote(kind),
          arguments: unquote(Macro.escape(arguments)),
          body: unquote(Macro.escape(body))
        }

      def resolvers, do: unquote(Macro.escape(resolvers))
    end
  end
end
