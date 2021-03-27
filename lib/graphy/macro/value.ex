defmodule Graphy.Macro.Value do
  @moduledoc false
  use Graphy.Macro

  defmacro __using__(_) do
    quote do
      alias Graphy.Macro.Value
      require Value

      defmacro value(name, resolver \\ quote(do: &identity/1)),
        do: {Value, [name, resolver]}
    end
  end

  def describe([name, _resolver], map, _references), do: Map.put(map, name, nil)
  def resolver([name, resolver], map, _references), do: Map.put(map, name, resolver)
end
