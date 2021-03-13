defmodule Graphy do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      require Graphy
      import Graphy
    end
  end

  defmacro field(data) do
    quote do
      {unquote(data), nil}
    end
  end

  defmacro field(name, _opts \\ [], do: body) do
    body = cleanup(body)

    quote do
      {unquote(name), Enum.into(unquote(body), %{})}
    end
  end

  defmacro interface(name, _opts \\ [], do: body) do
    body = cleanup(body)

    quote do
      {unquote(name), unquote(body)}
    end
  end

  defmacro object(_name, _opts \\ [], do: body) do
    body = cleanup(body)

    quote do
      def query, do: Enum.into(unquote(body), %{})
    end
  end

  defp cleanup(body) do
    body
    |> ast_to_list()
    |> filter_valid_macros()
  end

  defp ast_to_list(body) do
    case body do
      {:__block__, _, content} -> content
      other -> [other]
    end
  end

  defp filter_valid_macros(list),
    do:
      Enum.filter(list, fn {func_name, _, _} -> Enum.member?([:field, :interface], func_name) end)
end
