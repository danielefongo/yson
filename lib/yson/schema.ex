defmodule Yson.Schema do
  @moduledoc """
  Defines a Yson Schema that can be included in other schemas.

  It is the base of high level schemas like `Yson.GraphQL.Schema` and `Yson.Json.Schema`, and contains useful macros to build up Schema description and resolvers tree.

      defmodule Person do
        use Yson.Schema

        map :person do
          map :address do
            value(:street)
            value(:city)
          end
        end
      end

  Deep nesting is allowed but it is always possible to move a block outside and reference it with `reference/2`. The previous example could be changed as follows:

      defmodule Person do
        use Yson.Schema

        map :person do
          reference(:address)
        end

        map :address do
          value(:street)
          value(:city)
        end
      end
  """

  alias Yson.Util.Merge
  import Yson.Util.AST
  import Function, only: [identity: 1]

  @allowed_macros [:value, :reference, :map, :interface]
  @mapping %{map: :nested_map, interface: :nested_interface}

  defmacro __using__(_) do
    quote do
      require Yson.Schema
      import Yson.Schema
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    module = __CALLER__.module

    imported_references = Attributes.get(module, [:imported_references])
    references = Attributes.get(module, [:references])

    check_reference_conflicts(imported_references, references)
    squashed_refs = resolve_references(references, module, [])

    Attributes.set(module, [:references], squashed_refs)

    Attributes.update(module, [:root], &resolve_references(&1, module, []))
  end

  @doc """
  Imports schema main types from another `Yson.Schema` module.

  ### Examples
      defmodule Address do
        use Yson.Schema

        map :address do
          value(:city)
        end
      end

      defmodule Person do
        use Yson.Schema

        import_schema(Address)

        map :person do
          reference(:address)
        end
      end

  Imported schema is not public. If a module imports `Person` schema and needs to refer :address explicitly, it will need to import `Address` too.
  """
  defmacro import_schema(module_from) do
    module_to = __CALLER__.module

    quote do
      require unquote(module_from)

      imported_references = Attributes.get(unquote(module_from), [:references])

      Attributes.update(
        unquote(module_to),
        [:imported_references],
        &Merge.merge(&1, imported_references)
      )
    end
  end

  @doc """
  Defines the root of the schema.

  It contains the schema tree.
  A root field can be a value, a map, an interface or a reference.

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
      Attributes.set!(unquote(module), [:root], {:root, [unquote(resolver), unquote(fields)]})
    end
  end

  @doc """
  References a map or an interface by name.

  The referenced map/interface should be defined outside the `root/2` macro scope.

  ### Example
      map :any do
        reference(:referenced)
      end

      map :referenced do
        value(:name)
      end

  It is also possible to rename the referenced field:

  ### Example
      map :any do
        reference(:referenced, as: :my_field)
      end

      map :referenced do
        value(:name)
      end
  """
  defmacro reference(reference, opts \\ []) when is_list(opts) do
    {:reference, [reference, Keyword.get(opts, :as, reference)]}
  end

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
      Attributes.set!(unquote(module), [:references, unquote(name)], node)
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
      Attributes.set!(unquote(module), [:references, unquote(name)], node)
    end
  end

  @doc false
  defmacro nested_map(name, opts \\ [], do: body) do
    fields = get_fields(body)
    resolver = get_resolver(opts)

    {:map, [name, resolver, fields]}
  end

  @doc false
  def describe(module),
    do: module |> Attributes.get!([:root]) |> Macro.postwalk(&inner_describe/1)

  defp inner_describe({:root, [_res, fields]}), do: fields
  defp inner_describe({:map, [name, _res, fields]}), do: {name, fields}
  defp inner_describe({:interface, [name, fields]}), do: {name, {fields}}
  defp inner_describe({:value, [name, _res]}), do: name
  defp inner_describe(node), do: node

  @doc false
  def resolvers(module),
    do: module |> Attributes.get!([:root]) |> Macro.postwalk(&inner_resolver/1)

  defp inner_resolver({:root, [res, fields]}), do: {res, List.flatten(fields)}
  defp inner_resolver({:map, [name, res, fields]}), do: {name, {res, List.flatten(fields)}}
  defp inner_resolver({:interface, [_name, fields]}), do: fields
  defp inner_resolver({:value, [name, res]}), do: {name, res}
  defp inner_resolver(node), do: node

  defp get_resolver(opts), do: Keyword.get(opts, :resolver, &identity/1)
  defp get_fields(body), do: fetch(body, @allowed_macros, @mapping)

  defp resolve_references(nil, module, references_stack),
    do: resolve_references([], module, references_stack)

  defp resolve_references(references, module, references_stack) do
    Macro.postwalk(references, fn node ->
      case node do
        {:reference, [ref, as]} ->
          check_circular_references(references_stack, ref)

          {type, [_ | data]} =
            module
            |> get_ref(ref)
            |> resolve_references(module, references_stack ++ [ref])

          {type, [as] ++ data}

        _ ->
          node
      end
    end)
  end

  defp get_ref(module, ref) do
    case Attributes.get(module, [:imported_references, ref]) do
      nil -> Attributes.get!(module, [:references, ref])
      ref -> ref
    end
  end

  defp check_reference_conflicts(_, nil), do: :ok
  defp check_reference_conflicts(nil, _), do: :ok

  defp check_reference_conflicts(references, other_references) do
    references_keys = Keyword.keys(references)
    other_references_keys = Keyword.keys(other_references)

    conflicts =
      Enum.filter(references_keys, fn key -> Enum.member?(other_references_keys, key) end)

    if conflicts != [] do
      raise "Found conflicts: #{inspect(conflicts)}."
    end
  end

  defp check_circular_references(references_stack, reference) do
    if Enum.member?(references_stack, reference) do
      raise "Found circular dependency in #{inspect(references_stack)}"
    end
  end
end
