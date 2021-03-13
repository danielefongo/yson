defmodule GraphqlBuilder do
  @moduledoc false

  def build(%{kind: kind, object: object, arguments: arguments, body: body}) do
    query = build_query(arguments, kind)
    arguments = build_arguments(object, arguments)
    body = build_body(body)
    inner = [arguments <> " {"] ++ body ++ ["}"]
    Indent.indent([query <> " {", inner, "}"])
  end

  def build_query(arguments, kind) do
    inner = inner_build_query(arguments)

    case inner do
      "" -> "#{camel(kind)}"
      content -> "#{camel(kind)} (#{content})"
    end
  end

  defp inner_build_query(data) when data == %{}, do: ""

  defp inner_build_query(data) when is_map(data) do
    Enum.map(data, fn data -> inner_build_query(data) end) |> Enum.join(", ")
  end

  defp inner_build_query({key, value}) when is_atom(value), do: "$#{camel(key)}: #{pascal(value)}"

  defp inner_build_query({_, value}) when is_map(value), do: inner_build_query(value)

  def build_arguments(method, data) when is_map(data) do
    inner = inner_build_arguments(data)

    case inner do
      "" -> camel(method)
      content -> "#{method}(" <> content <> ")"
    end
  end

  defp inner_build_arguments(data) when is_map(data) do
    data |> Enum.map(fn data -> inner_build_arguments(data) end) |> Enum.join(", ")
  end

  defp inner_build_arguments({key, value}) when is_atom(value) do
    "#{camel(key)}: $#{camel(key)}"
  end

  defp inner_build_arguments({key, value}) when is_map(value) do
    inner = value |> Enum.map(fn value -> inner_build_arguments(value) end) |> Enum.join(", ")
    "#{camel(key)}: {" <> inner <> "}"
  end

  def build_body(data) when is_map(data), do: inner_build_body(data)

  def inner_build_body(data) when is_map(data) do
    data |> Enum.map(fn d -> inner_build_body(d) end)
  end

  def inner_build_body({key, value}) when is_nil(value) do
    [camel(key)]
  end

  def inner_build_body({key, value}) when is_map(value) do
    inner = value |> Enum.map(fn d -> inner_build_body(d) end)
    ["#{key} {"] ++ inner ++ ["}"]
  end

  def inner_build_body({key, value}) when is_list(value) do
    inner = value |> Enum.into(%{}) |> Enum.map(fn d -> inner_build_body(d) end)
    ["... on #{pascal(key)} {"] ++ inner ++ ["}"]
  end

  defp camel(value), do: value |> Atom.to_string() |> Recase.to_camel()
  defp pascal(value), do: value |> Atom.to_string() |> Recase.to_pascal()
end
