defmodule Yson.Schema do
  @moduledoc """
  Defines a Yson Schema that can be included other schemas.

  It is the base of high level schemas like `Yson.GraphQL.Schema` and `Yson.Json.Schema`, and contains useful macros to build up Schema description and resolvers tree.

      defmodule Person do
        use Yson.Schema

        root do
          map :address do
            value(:street)
            value(:city)
          end

          value(:name)
        end
      end

  Deep nesting is allowed but it always possible to move a block outside and reference it with `reference/1`. The previous example could be changed as follows:

      defmodule Person do
        use Yson.Schema

        root do
          reference(:address)
          value(:name)
        end

        map :address do
          value(:street)
          value(:city)
        end
      end
  """

  alias Yson.Util.Attributes
  alias Yson.Util.Merge
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

  @doc """
  Imports schema types from another `Yson.Schema` module.

  ### Examples
      defmodule Base do
        use Yson.Schema

        map :user do
          value(:name)
        end
      end

      defmodule Extension do
        use Yson.Schema

        import_schema(Base)

        root do
          reference(:user)
        end
      end
  """
  defmacro import_schema(module_from) do
    module_to = __CALLER__.module

    quote do
      require unquote(module_from)
      first_data = Attributes.get(unquote(module_from), :references)
      second_data = Attributes.get(unquote(module_to), :references)

      Attributes.set(unquote(module_to), :references, Merge.merge(first_data, second_data))
    end
  end

  @doc """
  Defines the root of the schema.

  It contains the schema tree and must be defined.
  A root field could be a value, a map, an interface or a reference.

  ### Examples
      root do
        value(:name)
      end

  You can also specify custom resolver to parse data.

  ### Example
      reverse_name = fn %{name: name} -> %{name: String.reverse(name)} end
      root resolver: &reverse_name/1 do
        value(:name)
      end
  """
  defmacro root(opts \\ [], do: body) do
    module = __CALLER__.module
    fields = get_fields(body)
    resolver = get_resolver(opts)

    quote do
      Attributes.set!(unquote(module), :root, [unquote(resolver), unquote(fields)])
    end
  end

  @doc """
  References a map or an interface by name.

  The referenced map/interface should be defined outside the `root/2` macro scope.

  ### Example
      root do
        reference(:referenced)
      end

      map :referenced do
        value(:name)
      end
  """
  defmacro reference(reference), do: {:reference, reference}

  @doc """
  Defines a simple field.

  ### Example
      value(:referenced)
  """
  defmacro value(name, resolver \\ quote(do: &identity/1)), do: {:value, [name, resolver]}

  @doc """
  Defines a interface.

  It contains virtual fields that will be automatically mapped on parent node as children.
  An interface field could be a value, a map, an interface or a reference.

  ### Example
      interface :address do
        value(:city)
      end
  """
  defmacro interface(name, _opts \\ [], do: body) do
    module = __CALLER__.module
    fields = get_fields(body)

    quote do
      node = {:interface, [unquote(name), unquote(fields)]}
      Attributes.set!(unquote(module), :references, unquote(name), node)
    end
  end

  @doc false
  defmacro nested_interface(name, _opts \\ [], do: body) do
    fields = get_fields(body)

    {:interface, [name, fields]}
  end

  @doc """
  Defines a map.

  A map field could be a value, a map, an interface or a reference.

  ### Example
      map :person do
        value(:name)
      end

  You can also specify custom resolver to parse data.

  ### Example
      reverse_name = fn %{name: name} -> %{name: String.reverse(name)} end
      map :person, resolver: &reverse_name/1 do
        value(:name)
      end
  """
  defmacro map(name, opts \\ [], do: body) do
    module = __CALLER__.module
    fields = get_fields(body)
    resolver = get_resolver(opts)

    quote do
      node = {:map, [unquote(name), unquote(resolver), unquote(fields)]}
      Attributes.set!(unquote(module), :references, unquote(name), node)
    end
  end

  @doc false
  defmacro nested_map(name, opts \\ [], do: body) do
    fields = get_fields(body)
    resolver = get_resolver(opts)

    {:map, [name, resolver, fields]}
  end

  @doc false
  def describe(module) do
    [_, description] = Attributes.get!(module, :root)

    Enum.reduce(description, %{}, fn data, m -> describe(data, m, module) end)
  end

  @doc false
  def resolvers(module) do
    [resolver, description] = Attributes.get!(module, :root)

    resolvers = Enum.reduce(description, %{}, fn data, m -> resolver(data, m, module) end)

    {resolver, resolvers}
  end

  defp describe({:reference, ref}, map, module) do
    module
    |> Attributes.get!(:references, ref)
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
    |> Attributes.get!(:references, ref)
    |> resolver(%{}, module)
    |> Map.merge(map)
  end

  defp get_resolver(opts), do: Keyword.get(opts, :resolver, &identity/1)
  defp get_fields(body), do: fetch(body, @allowed_macros, @mapping)
end