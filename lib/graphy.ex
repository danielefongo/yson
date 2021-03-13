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

    kind = Module.get_attribute(module, :kind)
    object = Module.get_attribute(module, :object)
    arguments = Module.get_attribute(module, :arguments)
    body = Module.get_attribute(module, :body)

    quote do
      def describe do
        %{
          kind: unquote(kind),
          object: unquote(object),
          arguments: Enum.into(unquote(arguments), %{}),
          body: Enum.into(unquote(body), %{})
        }
      end
    end
  end

  defmacro arg(key, type) when is_atom(type) do
    quote do
      {unquote(key), unquote(type)}
    end
  end

  defmacro arg(name, _opts \\ [], do: body) do
    body = cleanup(body, [:arg])

    quote do
      {unquote(name), Enum.into(unquote(body), %{})}
    end
  end

  defmacro query(_opts \\ [], do: body) do
    body = cleanup(body, [:arg])
    module = __CALLER__.module

    Module.put_attribute(module, :kind, :query)
    Module.put_attribute(module, :arguments, body)

    quote do
      Enum.into(unquote(body), %{})
    end
  end

  defmacro mutation(_opts \\ [], do: body) do
    body = cleanup(body, [:arg])
    module = __CALLER__.module

    Module.put_attribute(module, :kind, :mutation)
    Module.put_attribute(module, :arguments, body)

    quote do
      Enum.into(unquote(body), %{})
    end
  end

  defmacro field(data) do
    quote do
      {unquote(data), nil}
    end
  end

  defmacro field(name, _opts \\ [], do: body) do
    body = cleanup(body, [:field, :interface])

    quote do
      {unquote(name), Enum.into(unquote(body), %{})}
    end
  end

  defmacro interface(name, _opts \\ [], do: body) do
    body = cleanup(body, [:field, :interface])

    quote do
      {unquote(name), unquote(body)}
    end
  end

  defmacro object(object, _opts \\ [], do: body) do
    body = cleanup(body, [:field, :interface])
    module = __CALLER__.module

    Module.put_attribute(module, :object, object)
    Module.put_attribute(module, :body, body)

    quote do
      Enum.into(unquote(body), %{})
    end
  end

  defp cleanup(body, allowed) do
    body
    |> ast_to_list()
    |> filter_valid_macros(allowed)
  end

  defp ast_to_list(body) do
    case body do
      {:__block__, _, content} -> content
      other -> [other]
    end
  end

  defp filter_valid_macros(list, allowed),
    do: Enum.filter(list, fn {func_name, _, _} -> Enum.member?(allowed, func_name) end)
end
