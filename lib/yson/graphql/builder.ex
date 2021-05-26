defmodule Yson.GraphQL.Builder do
  @moduledoc """
  Defines the GraphQL request builder.

      iex> variables = %{key: "value"}
      iex> Yson.GraphQL.Builder.build(ASchema.describe(), variables)
      iex> %{
        query: "query ($key: String) ...",
        variables: %{key: "value"}
      }
  """

  alias Yson.Util

  @doc """
  Builds the request.

  The first parameter is a `Yson.GraphQL.Schema` description, while the second parameter is a map of variables.

  ### Example
      build(ASchema.describe(), %{key: "value"})

  You can pass a shallow map of variables even if you specified deep args on `Yson.GraphQL.Schema.query/3` or `Yson.GraphQL.Schema.mutation/3`.

  ### Example
      defmodule Person do
        use Yson.GraphQL.Schema

        query :person do
          arg :addresso do
            arg(:street, :string)
          end
        end

        # ...
      end

      # ...
      build(Person.describe(), %{street: "a street"})
  """
  def build(description, variables) do
    %{kind: kind, object: object, arguments: arguments, body: body} = description

    variables = fetch_variables(variables, arguments)

    query =
      Util.Indent.indent([
        build_query(arguments, kind) <> " {",
        [build_arguments(object, arguments) <> " {"] ++ build_body(body[object]) ++ ["}"],
        "}"
      ])

    %{
      query: query,
      variables: variables
    }
  end

  defp fetch_variables(variables, arguments) do
    flat_arguments = Util.Map.flatten(arguments)
    var_keys = Map.keys(variables)
    arg_keys = Map.keys(flat_arguments)

    if not Util.Map.has_keys?(variables, arg_keys) do
      raise "Invalid variables: expected #{inspect(arg_keys)}, actual #{inspect(var_keys)}."
    end

    Util.Map.subset(variables, arg_keys)
  end

  defp build_query(arguments, kind) do
    case inner_build_query(arguments) do
      "" -> "#{camel(kind)}"
      content -> "#{camel(kind)} (#{content})"
    end
  end

  defp inner_build_query(data) when data == %{}, do: ""

  defp inner_build_query(data) when is_map(data) do
    data |> Enum.map(&inner_build_query/1) |> Enum.join(", ")
  end

  defp inner_build_query({key, value}) when is_atom(value), do: "$#{camel(key)}: #{pascal(value)}"

  defp inner_build_query({_, value}) when is_map(value), do: inner_build_query(value)

  defp build_arguments(method, data) when is_map(data) do
    case inner_build_arguments(data) do
      "" -> camel(method)
      content -> "#{method}(#{content})"
    end
  end

  defp inner_build_arguments(data) when is_map(data) do
    data |> Enum.map(&inner_build_arguments/1) |> Enum.join(", ")
  end

  defp inner_build_arguments({key, value}) when is_atom(value) do
    "#{camel(key)}: $#{camel(key)}"
  end

  defp inner_build_arguments({key, value}) when is_map(value) do
    inner = value |> Enum.map(&inner_build_arguments/1) |> Enum.join(", ")
    "#{camel(key)}: {#{inner}}"
  end

  defp build_body(data) when is_map(data), do: inner_build_body(data)

  defp inner_build_body(data) when is_map(data), do: Enum.map(data, &inner_build_body/1)

  defp inner_build_body({key, value}) when is_nil(value), do: [camel(key)]

  defp inner_build_body({key, value}) when is_map(value) do
    inner = Enum.map(value, &inner_build_body/1)
    ["#{key} {"] ++ inner ++ ["}"]
  end

  defp inner_build_body({key, value}) when is_list(value) do
    inner = value |> Enum.into(%{}) |> Enum.map(&inner_build_body/1)
    ["... on #{pascal(key)} {"] ++ inner ++ ["}"]
  end

  defp camel(value), do: value |> Atom.to_string() |> Recase.to_camel()
  defp pascal(value), do: value |> Atom.to_string() |> Recase.to_pascal()
end
