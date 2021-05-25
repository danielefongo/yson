defmodule Yson.Schema do
  @moduledoc false
  alias Yson.Util.Attributes
  alias Yson.Util.Merge
  alias Yson.Util.Reference
  import Yson.Util.AST
  import Function, only: [identity: 1]

  @allowed_macros [:value, :reference, :map, :interface]
  @mapping %{map: :nested_map, interface: :nested_interface}

  defmacro __using__(_) do
    quote do
      require Yson.Schema
      import Yson.Schema
    end
  end

  defmacro import_schema(module_from) do
    module_to = __CALLER__.module

    quote do
      require unquote(module_from)
      first_data = Reference.get_references(unquote(module_from))
      second_data = Reference.get_references(unquote(module_to))

      Reference.set_references(unquote(module_to), Merge.merge(first_data, second_data))
    end
  end

  defmacro root(opts \\ [], do: body) do
    module = __CALLER__.module
    fields = get_fields(body)
    resolver = get_resolver(opts)

    quote do
      Attributes.set(unquote(module), :root, [unquote(resolver), unquote(fields)])
    end
  end

  defmacro reference(reference), do: {:reference, reference}

  defmacro value(name, resolver \\ quote(do: &identity/1)), do: {:value, [name, resolver]}

  defmacro interface(name, _opts \\ [], do: body) do
    module = __CALLER__.module
    fields = get_fields(body)

    quote do
      node = {:interface, [unquote(name), unquote(fields)]}
      Reference.set_reference(unquote(module), unquote(name), node)
    end
  end

  defmacro nested_interface(name, _opts \\ [], do: body) do
    fields = get_fields(body)

    {:interface, [name, fields]}
  end

  defmacro map(name, opts \\ [], do: body) do
    module = __CALLER__.module
    fields = get_fields(body)
    resolver = get_resolver(opts)

    quote do
      node = {:map, [unquote(name), unquote(resolver), unquote(fields)]}
      Reference.set_reference(unquote(module), unquote(name), node)
    end
  end

  defmacro nested_map(name, opts \\ [], do: body) do
    fields = get_fields(body)
    resolver = get_resolver(opts)

    {:map, [name, resolver, fields]}
  end

  def describe(module) do
    [_, description] = Attributes.get(module, :root)

    Enum.reduce(description, %{}, fn data, m -> describe(data, m, module) end)
  end

  def resolvers(module) do
    [resolver, description] = Attributes.get(module, :root)

    resolvers = Enum.reduce(description, %{}, fn data, m -> resolver(data, m, module) end)

    {resolver, resolvers}
  end

  defp describe({:reference, ref}, map, module) do
    module
    |> Reference.get_reference(ref)
    |> describe(%{}, module)
    |> Map.merge(map)
  end

  defp describe({:interface, [name, list]}, map, module) do
    inner_keywords =
      list
      |> Enum.reduce(%{}, fn data, m -> describe(data, m, module) end)
      |> Enum.to_list()

    Map.put(map, name, inner_keywords)
  end

  defp describe({:map, [name, _resolver, list]}, map, module) do
    inner_map = Enum.reduce(list, %{}, fn data, m -> describe(data, m, module) end)

    Map.put(map, name, inner_map)
  end

  defp describe({:value, [name, _resolver]}, map, _module), do: Map.put(map, name, nil)

  defp resolver({:interface, [_name, list]}, map, module) do
    list
    |> Enum.reduce(%{}, fn data, m -> resolver(data, m, module) end)
    |> Map.merge(map)
  end

  defp resolver({:value, [name, resolver]}, map, _module), do: Map.put(map, name, resolver)

  defp resolver({:map, [name, resolver, list]}, map, module) do
    inner_resolvers = Enum.reduce(list, %{}, fn data, m -> resolver(data, m, module) end)

    Map.put(map, name, {resolver, inner_resolvers})
  end

  defp resolver({:reference, ref}, map, module) do
    module
    |> Reference.get_reference(ref)
    |> resolver(%{}, module)
    |> Map.merge(map)
  end

  defp get_resolver(opts), do: Keyword.get(opts, :resolver, &identity/1)
  defp get_fields(body), do: fetch(body, @allowed_macros, @mapping)
end
