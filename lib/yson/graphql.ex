defmodule Yson.GraphQL do
  @moduledoc false
  use Yson.Macro
  use Yson.Macro.{Arg, Interface, Map, Reference, Value}

  defmacro __using__(_) do
    quote do
      require Yson.GraphQL
      import Yson.GraphQL
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    kind = Module.get_attribute(module, :kind)
    object = Module.get_attribute(module, :object)
    arguments = Module.get_attribute(module, :arguments)
    references = Module.get_attribute(module, :references)
    {module, data} = Keyword.get(references, object)

    body = module.describe(data, %{}, references)
    resolvers = module.resolver(data, %{}, references)

    quote do
      def describe do
        %{
          kind: unquote(kind),
          object: unquote(object),
          arguments: Enum.into(unquote(arguments), %{}),
          body: unquote(Macro.escape(body))
        }
      end

      def resolvers, do: unquote(Macro.escape(resolvers))
    end
  end

  defmacro query(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :query, body)

  defmacro mutation(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :mutation, body)

  defp request(module, name, kind, body) do
    body = fetch(body, [:arg])

    Module.put_attribute(module, :kind, Macro.escape(kind))
    Module.put_attribute(module, :object, name)
    Module.put_attribute(module, :arguments, body)

    quote do
      Enum.into(unquote(body), %{})
    end
  end
end
