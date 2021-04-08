defmodule Yson.GraphQL.Builder do
  @moduledoc false
  alias Yson.Util

  def build(%{kind: kind, object: object, arguments: arguments, body: body}, variables) do
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

  def build_query(arguments, kind) do
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

  def build_arguments(method, data) when is_map(data) do
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

  def build_body(data) when is_map(data), do: inner_build_body(data)

  def inner_build_body(data) when is_map(data), do: Enum.map(data, &inner_build_body/1)

  def inner_build_body({key, value}) when is_nil(value), do: [camel(key)]

  def inner_build_body({key, value}) when is_map(value) do
    inner = Enum.map(value, &inner_build_body/1)
    ["#{key} {"] ++ inner ++ ["}"]
  end

  def inner_build_body({key, value}) when is_list(value) do
    inner = value |> Enum.into(%{}) |> Enum.map(&inner_build_body/1)
    ["... on #{pascal(key)} {"] ++ inner ++ ["}"]
  end

  defp camel(value), do: value |> Atom.to_string() |> Recase.to_camel()
  defp pascal(value), do: value |> Atom.to_string() |> Recase.to_pascal()
end
