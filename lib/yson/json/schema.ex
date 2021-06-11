defmodule Yson.Json.Schema do
  @moduledoc """
  Defines a Yson Json Schema.

  It is an extension of `Yson.Schema` that represents a Json response object.
  The parsing of the JSON is defined by the `Yson.Schema.root/2` tree.

      defmodule Person do
        use Yson.Yson.Schema

        root do
          map :address do
            value(:street)
            value(:city)
          end

          value(:name)
        end
      end

  Root must be defined once using `Yson.Schema.root/2` macro.

  After the definition, a Json Schema exposes two methods:
  - `describe/0`, to build the object description.
  - `resolvers/0`, to build the object resolvers tree. It can be used with `Yson.Parser.parse/3` to parse json response.
  """

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
    Attributes.delete(module)

    quote do
      def describe, do: unquote(body)
      def resolvers, do: unquote(resolvers)
    end
  end
end
