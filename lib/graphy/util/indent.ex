defmodule Graphy.Util.Indent do
  @moduledoc false
  @indentation "  "

  def indent(data, starting_indentation \\ 0), do: inner_indent(data, starting_indentation)

  def inner_indent(data, indentation) when is_binary(data), do: spaces(indentation) <> data

  def inner_indent(data, indentation) when is_list(data) do
    data
    |> Enum.map(fn element ->
      new_indentation = if is_list(element), do: indentation + 1, else: indentation
      indent(element, new_indentation)
    end)
    |> Enum.join("\n")
  end

  defp spaces(number), do: String.duplicate(@indentation, number)
end
