defmodule Yson.GraphQL.Schema do
  @moduledoc """
  Defines a Yson GraphQL Schema.

  It is an extension of `Yson.Schema` that represents a GraphQL request and response object.
  The request is built using `query/3` or `mutation/3` while the response and its parsing by the `Yson.Schema.root/2` tree.

      defmodule Person do
        use Yson.GraphQL.Schema

        query :person do
          arg(:street, :string)
        end

        root do
          map :address do
            value(:street)
            value(:city)
          end

          value(:name)
        end
      end

  After the definition, a GraphQL Schema exposes two methods:
  - `describe/0`, to build the object description. It can be used with `Yson.GraphQL.Builder.build/2` to create a GraphQL request.
  - `resolvers/0`, to build the object resolvers tree. It can be used with `Yson.Parser.parse/3` to parse a GraphQL response.
  """

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

    request = Attributes.get!(module, :request)

    object = request[:object]
    kind = request[:kind]
    arguments = Enum.into(request[:arguments], %{})

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

  @doc """
  Defines a basic GraphQL argument.

  It can be used inside `mutation/3`, `query/3` or `arg/3` macros.

  ### Examples
      arg(:name, :string)
  """
  defmacro arg(name, type) when is_atom(type) do
    quote do: {unquote(name), unquote(type)}
  end

  @doc """
  Defines a complex GraphQL argument.

  It contains args and can be used inside `mutation/3`, `query/3` or `arg/3` macros.

  ### Examples
      arg :address do
        arg(:street, :string)
        arg(:city, :string)
      end
  """
  defmacro arg(name, _opts \\ [], do: body) do
    args = fetch(body, @allowed_macros)

    quote do: {unquote(name), Enum.into(unquote(args), %{})}
  end

  @doc """
  Defines a GraphQL query.

  It specifies the query name and its arguments.

  ### Examples
      query :person do
        arg(:street, :string)
      end
  """
  defmacro query(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :query, body)

  @doc """
  Defines a GraphQL mutation.

  It specifies the mutation name and its arguments.

  ### Examples
      mutation :person do
        arg(:street, :string)
      end
  """
  defmacro mutation(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :mutation, body)

  defp request(module, name, kind, body) do
    body = fetch(body, @allowed_macros)

    quote do
      Attributes.set!(unquote(module), :request,
        kind: unquote(kind),
        object: unquote(name),
        arguments: unquote(body)
      )

      Enum.into(unquote(body), %{})
    end
  end
end
