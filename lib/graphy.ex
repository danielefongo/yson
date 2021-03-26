defmodule Graphy do
  @moduledoc false
  import Function, only: [identity: 1]

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
    objects = Module.get_attribute(module, :objects)
    references = Module.get_attribute(module, :references)
    arguments = Module.get_attribute(module, :arguments)

    quote do
      def describe do
        %{
          kind: unquote(kind),
          object: unquote(object),
          arguments: Enum.into(unquote(arguments), %{}),
          body: body()
        }
      end

      def body do
        Enum.reduce(unquote(objects), %{}, fn {_, val} = node, map -> build_body(val, map) end)
      end

      def resolvers do
        Enum.reduce(unquote(objects), %{}, fn {_, val} = node, map ->
          build_resolvers(val, map)
        end)
      end

      defp build_body([:map, nested, name, _resolver, list], map) when is_list(list) do
        inner_map = Enum.reduce(list, build_map(map, nested), &build_body/2)
        Map.put(map, name, inner_map)
      end

      defp build_body([:interface, nested, name, _resolver, list], map) when is_list(list) do
        inner_keywords =
          list
          |> Enum.reduce(build_map(map, nested), &build_body/2)
          |> Enum.to_list()

        Map.put(map, name, inner_keywords)
      end

      defp build_body([:field, atom, _resolver], map), do: Map.put(map, atom, nil)

      defp build_body([:ref, atom, ref], map) do
        unquote(references)
        |> Keyword.get(ref)
        |> build_body(%{})
        |> Map.merge(map)
      end

      defp build_resolvers([:map, nested, name, resolver, list], map) when is_list(list) do
        inner_resolvers = Enum.reduce(list, build_map(map, nested), &build_resolvers/2)
        Map.put(map, name, {resolver, inner_resolvers})
      end

      defp build_resolvers([:interface, nested, name, resolver, list], map) when is_list(list) do
        list
        |> Enum.reduce(build_map(map, nested), &build_resolvers/2)
        |> Map.merge(map)
      end

      defp build_resolvers([:field, atom, resolver], map) do
        Map.put(map, atom, resolver)
      end

      defp build_resolvers([:ref, atom, ref], map) do
        unquote(references)
        |> Keyword.get(ref)
        |> build_resolvers(%{})
        |> Map.merge(map)
      end

      defp build_map(map, nested), do: if(nested, do: %{}, else: map)
    end
  end

  defmacro arg(name, type) when is_atom(type) do
    quote do
      {unquote(name), unquote(type)}
    end
  end

  defmacro arg(name, _opts \\ [], do: body) do
    args = fetch_args(body)

    quote do
      {unquote(name), Enum.into(unquote(args), %{})}
    end
  end

  defmacro query(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :query, body)

  defmacro mutation(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :mutation, body)

  defmacro value(name, resolver \\ quote(do: &identity/1)), do: [:field, name, resolver]

  defmacro ref(name, reference), do: [:ref, name, reference]

  defmacro map(name, opts \\ [], do: body) do
    fields = fetch_fields(body)
    resolver = fetch_resolver(opts)

    node = quote do: [:map, false, unquote(name), unquote(resolver), unquote(fields)]

    update_attributes(:references, name, node)
  end

  defmacro nested_map(name, opts \\ [], do: body) do
    fields = fetch_fields(body)
    resolver = fetch_resolver(opts)

    [:map, true, name, resolver, fields]
  end

  defmacro interface(name, _opts \\ [], do: body) do
    fields = fetch_fields(body)

    node = quote do: [:interface, false, unquote(name), &identity/1, unquote(fields)]

    update_attributes(:references, name, node)
  end

  defmacro nested_interface(name, _opts \\ [], do: body) do
    fields = fetch_fields(body)

    [:interface, true, name, &identity/1, fields]
  end

  defmacro object(name, opts \\ [], do: body) do
    fields = fetch_fields(body)
    resolver = fetch_resolver(opts)

    node = quote do: [:map, false, unquote(name), unquote(resolver), unquote(fields)]

    update_attributes(:objects, name, node)
  end

  defp update_attributes(category, name, keywords, update \\ true) do
    quote do
      if :elixir_module.mode(__MODULE__) == :all and unquote(update) do
        data = Module.get_attribute(__MODULE__, unquote(category), [])
        data = Keyword.put(data, unquote(name), unquote(keywords))
        Module.put_attribute(__MODULE__, unquote(category), data)
      end

      unquote(keywords)
    end
  end

  defp request(module, name, kind, body) do
    body = fetch_args(body)

    Module.put_attribute(module, :kind, Macro.escape(kind))
    Module.put_attribute(module, :arguments, body)
    Module.put_attribute(module, :object, name)

    quote do
      Enum.into(unquote(body), %{})
    end
  end

  defp fetch_resolver(options) do
    quote do
      Keyword.get(unquote(options), :resolver, &identity/1)
    end
  end

  defp fetch_fields(body) do
    body
    |> ast_to_list()
    |> find_valid_macros([:value, :ref, :map, :interface])
    |> transform(%{map: :nested_map, interface: :nested_interface})
  end

  defp fetch_args(body) do
    body
    |> ast_to_list()
    |> find_valid_macros([:arg])
  end

  defp ast_to_list(body) do
    case body do
      {:__block__, _, content} -> content
      other -> [other]
    end
  end

  defp find_valid_macros(list, allowed),
    do: Enum.filter(list, fn {marker, _, _} -> Enum.member?(allowed, marker) end)

  defp transform(list, mapping),
    do:
      Enum.map(list, fn {marker, metadata, children} ->
        new_marker = Map.get(mapping, marker, marker)
        {new_marker, metadata, children}
      end)
end
