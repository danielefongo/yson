defmodule GraphqlBuilder do
  @moduledoc false

  def build_query(arguments) do
    inner = inner_build_query(arguments)

    case inner do
      "" -> "query"
      content -> "query (#{content})"
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

  def build_body(method, arguments, data) when is_map(data) do
    query = build_query(arguments)
    args = build_arguments(method, arguments)
    inner = inner_build_body(args, data, 1) |> Enum.join("\n")
    [query <> " {", inner, "}"] |> Enum.join("\n")
  end

  def inner_build_body(prefix, data, indentation) when is_map(data) do
    inner = data |> Enum.map(fn d -> inner_build_body("", d, indentation) end)
    indent([prefix <> " {", inner, "}"], indentation)
  end

  def inner_build_body(_prefix, {key, value}, indentation) when is_nil(value) do
    indent([camel(key)], indentation)
  end

  def inner_build_body(prefix, {key, value}, indentation) when is_map(value) do
    inner = value |> Enum.map(fn d -> inner_build_body(prefix, d, indentation) end)
    indent(["#{key} {", inner, "}"], indentation)
  end

  def inner_build_body(prefix, {key, value}, indentation) when is_list(value) do
    inner = value |> Enum.into(%{}) |> Enum.map(fn d -> inner_build_body(prefix, d, indentation) end)
    indent(["... on #{pascal(key)} {", inner, "}"], indentation)
  end

  defp indent(data, indentation),
    do: data |> List.flatten() |> Enum.map(fn d -> indent(indentation) <> d end)

  defp indent(indentation), do: String.duplicate("  ", indentation)

  defp camel(value), do: value |> Atom.to_string() |> Recase.to_camel()
  defp pascal(value), do: value |> Atom.to_string() |> Recase.to_pascal()
end
