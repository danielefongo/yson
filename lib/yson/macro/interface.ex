defmodule Yson.Macro.Interface do
  @moduledoc false
  use Yson.Macro

  defmacro __using__(_) do
    quote do
      use Yson.Macro
      alias Yson.Macro.Interface
      require Interface

      @allowed_macros [:value, :reference, :map, :interface]
      @mapping %{map: :nested_map, interface: :nested_interface}

      defmacro interface(name, _opts \\ [], do: body) do
        fields = fetch(body, @allowed_macros, @mapping)

        node = quote do: {Interface, [unquote(name), unquote(fields)]}

        update_attributes(:references, name, node)
      end

      defmacro nested_interface(name, _opts \\ [], do: body) do
        fields = fetch(body, @allowed_macros, @mapping)

        {Interface, [name, fields]}
      end
    end
  end

  def describe([name, list], map, references) do
    inner_keywords =
      list
      |> Enum.reduce(%{}, fn {module, value}, m -> module.describe(value, m, references) end)
      |> Enum.to_list()

    Map.put(map, name, inner_keywords)
  end

  def resolver([_name, list], map, references) do
    list
    |> Enum.reduce(%{}, fn {module, value}, m -> module.resolver(value, m, references) end)
    |> Map.merge(map)
  end
end
