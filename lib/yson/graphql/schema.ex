defmodule Yson.GraphQL.Schema do
  @moduledoc false
  import Yson.Util.AST
  alias Yson.Util.Attributes

  @allowed_macros [:arg]

  defmacro __using__(_) do
    quote do
      use Yson.Schema

      require Yson.GraphQL.Schema
      import Yson.GraphQL.Schema

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    object = object(module)
    kind = kind(module)
    arguments = arguments(module)

    body = Map.put(%{}, object, Yson.Schema.describe(module))
    resolvers = Map.put(%{}, object, Yson.Schema.resolvers(module))

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

  defmacro arg(name, type) when is_atom(type) do
    quote do: {unquote(name), unquote(type)}
  end

  defmacro arg(name, _opts \\ [], do: body) do
    args = fetch(body, @allowed_macros)

    quote do: {unquote(name), Enum.into(unquote(args), %{})}
  end

  defmacro query(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :query, body)

  defmacro mutation(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :mutation, body)

  defp request(module, name, kind, body) do
    body = fetch(body, @allowed_macros)

    quote do
      Attributes.set(unquote(module),
        kind: unquote(kind),
        object: unquote(name),
        arguments: unquote(body)
      )

      Enum.into(unquote(body), %{})
    end
  end

  defp kind(module), do: Attributes.get(module, :kind)
  defp object(module), do: Attributes.get(module, :object)
  defp arguments(module), do: module |> Attributes.get(:arguments) |> Enum.into(%{})
end
