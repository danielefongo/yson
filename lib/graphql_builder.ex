defmodule GraphqlBuilder do
  @moduledoc false

  def build(data) when is_struct(data), do: data |> Map.from_struct() |> build
  def build(data) when is_map(data), do: inner_build(data, 0) |> Enum.join("\n")

  def inner_build(data, indentation) when is_map(data) do
    inner = data |> Enum.map(fn d -> inner_build(d, indentation + 1) end)
    indent(["{", inner, "}"], indentation)
  end

  def inner_build({key, value}, indentation) when is_nil(value) do
    indent([camel(key)], indentation)
  end

  def inner_build({key, value}, indentation) when is_map(value) do
    inner = value |> Enum.map(fn d -> inner_build(d, indentation) end)
    indent(["#{key} {", inner, "}"], indentation)
  end

  def inner_build({key, value}, indentation) when is_list(value) do
    inner = value |> Enum.into(%{}) |> Enum.map(fn d -> inner_build(d, indentation) end)
    indent(["... on #{pascal(key)} {", inner, "}"], indentation)
  end

  defp indent(data, indentation),
    do: data |> List.flatten() |> Enum.map(fn d -> indent(indentation) <> d end)

  defp indent(indentation), do: String.duplicate("  ", indentation)

  defp camel(value), do: value |> Atom.to_string() |> Recase.to_camel()
  defp pascal(value), do: value |> Atom.to_string() |> Recase.to_pascal()
end
