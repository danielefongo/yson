defmodule Graphy.Macro.Interface do
  @moduledoc false
  use Graphy.Macro

  defmacro __using__(_) do
    quote do
      use Graphy.Macro
      alias Graphy.Macro.Interface
      require Interface

      @allowed_macros [:value, :ref, :map, :interface]
      @mapping %{map: :nested_map, interface: :nested_interface}

      defmacro interface(name, _opts \\ [], do: body) do
        fields = fetch(body, @allowed_macros, @mapping)

        node = quote do: {Interface, [false, unquote(name), &identity/1, unquote(fields)]}

        update_attributes(:references, name, node)
      end

      defmacro nested_interface(name, _opts \\ [], do: body) do
        fields = fetch(body, @allowed_macros, @mapping)

        {Interface, [true, name, &identity/1, fields]}
      end
    end
  end

  def describe([nested, name, _resolver, list], map, references) do
    inner_keywords =
      list
      |> Enum.reduce(build_map(map, nested), fn {module, value}, m ->
        module.describe(value, m, references)
      end)
      |> Enum.to_list()

    Map.put(map, name, inner_keywords)
  end

  def resolver([nested, _name, _resolver, list], map, references) do
    list
    |> Enum.reduce(build_map(map, nested), fn {module, value}, m ->
      module.resolver(value, m, references)
    end)
    |> Map.merge(map)
  end

  defp build_map(map, nested), do: if(nested, do: %{}, else: map)
end
