defmodule Graphy do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      require Graphy
      import Graphy
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    body = Module.get_attribute(module, :body, [])
    object = Module.get_attribute(module, :object, [])

    quote do
      def query do
        %{
          object: unquote(object),
          body: Enum.into(unquote(body), %{})
        }
      end
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

  defmacro object(object, _opts \\ [], do: body) do
    body = cleanup(body)
    module = __CALLER__.module

    quote do
      Module.put_attribute(unquote(module), :object, unquote(object))
      Module.put_attribute(unquote(module), :body, unquote(body))
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
