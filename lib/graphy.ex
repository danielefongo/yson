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
    resolvers = Module.get_attribute(module, :resolvers)

    quote do
      def describe do
        %{
          kind: unquote(kind),
          object: unquote(object),
          arguments: Enum.into(unquote(arguments), %{}),
          body: Enum.into(unquote(body), %{})
        }
      end

      def resolvers, do: Enum.into(unquote(resolvers), %{})
    end
  end

  defmacro arg(key, type) when is_atom(type) do
    quote do
      {unquote(key), unquote(type)}
    end
  end

  defmacro arg(name, _opts \\ [], do: body) do
    body = fetch_args(body)

    quote do
      {unquote(name), Enum.into(unquote(body), %{})}
    end
  end

  defmacro query(_opts \\ [], do: body) do
    body = fetch_args(body)
    module = __CALLER__.module

    Module.put_attribute(module, :kind, :query)
    Module.put_attribute(module, :arguments, body)

    quote do
      Enum.into(unquote(body), %{})
    end
  end

  defmacro mutation(_opts \\ [], do: body) do
    body = fetch_args(body)
    module = __CALLER__.module

    Module.put_attribute(module, :kind, :mutation)
    Module.put_attribute(module, :arguments, body)

    quote do
      Enum.into(unquote(body), %{})
    end
  end

  defmacro resolver(fun), do: fun

  defmacro field(data) do
    field = quote do: {unquote(data), nil}
    resolvers = quote do: {unquote(data), &void_resolver/1}

    quote do
      {
        unquote(field),
        unquote(resolvers)
      }
    end
  end

  defmacro field(name, _opts \\ [], do: body) do
    fields = fetch_fields(body)
    resolver = fetch_resolver(body)

    nested_fields = fetch_nested_fields(fields, true)
    nested_resolvers = fetch_nested_resolvers(fields, true)

    quote do
      {
        {unquote(name), unquote(nested_fields)},
        {unquote(name), {unquote(resolver), unquote(nested_resolvers)}}
      }
    end
  end

  defmacro interface(name, _opts \\ [], do: body) do
    fields = fetch_fields(body)

    nested_fields = fetch_nested_fields(fields)
    nested_resolvers = fetch_nested_resolvers(fields, true)

    quote do
      {
        {unquote(name), unquote(nested_fields)},
        {unquote(name), unquote(nested_resolvers)}
      }
    end
  end

  defmacro object(object, _opts \\ [], do: body) do
    module = __CALLER__.module

    fields = fetch_fields(body)
    resolver = fetch_resolver(body)

    nested_fields = fetch_nested_fields(fields, true)
    nested_resolvers = fetch_nested_resolvers(fields, true)

    resolvers = quote do
      Map.put(%{}, unquote(object), {unquote(resolver), unquote(nested_resolvers)})
    end

    Module.put_attribute(module, :object, object)
    Module.put_attribute(module, :body, nested_fields)
    Module.put_attribute(module, :resolvers, resolvers)

    quote do
      {
        unquote(nested_fields),
        unquote(resolvers)
      }
    end
  end

  defp fetch_resolver(body) do
    body
    |> ast_to_list()
    |> find_valid_macros([:resolver], &Enum.find/2)
    |> case do
      nil -> quote do: &void_resolver/1
      r -> r
    end
  end

  defp fetch_nested_resolvers(fields, to_map \\ false) do
    quote do
      nested = unquote(fields)
      |> Enum.map(fn {_, resolver} -> resolver end)
      |> Enum.map(fn {k, inner} -> if is_map(inner), do: Map.to_list(inner), else: {k, inner} end)
      |> List.flatten()

      if unquote(to_map), do: Enum.into(nested, %{}), else: nested
    end
  end

  defp fetch_fields(body) do
    body
    |> ast_to_list()
    |> find_valid_macros([:field, :interface], &Enum.filter/2)
  end

  defp fetch_nested_fields(fields, to_map \\ false) do
    quote do
      nested = Enum.map(unquote(fields), fn {field, _} -> field end)
      if unquote(to_map), do: Enum.into(nested, %{}), else: nested
    end
  end

  defp fetch_args(body) do
    body
    |> ast_to_list()
    |> find_valid_macros([:arg], &Enum.filter/2)
  end

  defp ast_to_list(body) do
    case body do
      {:__block__, _, content} -> content
      other -> [other]
    end
  end

  defp find_valid_macros(list, allowed, method),
    do: method.(list, fn {func_name, _, _} -> Enum.member?(allowed, func_name) end)

  def void_resolver(data), do: data
end
