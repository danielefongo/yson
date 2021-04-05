defmodule Yson.Macro.Value do
  @moduledoc false
  alias __MODULE__

  defmacro value(name, resolver \\ quote(do: &Function.identity/1)),
    do: {Value, [name, resolver]}

  def describe([name, _resolver], map, _module), do: Map.put(map, name, nil)
  def resolver([name, resolver], map, _module), do: Map.put(map, name, resolver)
end
