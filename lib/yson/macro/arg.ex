defmodule Yson.Macro.Arg do
  @moduledoc false
  import Yson.Util.AST

  @allowed_macros [:arg]

  defmacro arg(name, type) when is_atom(type) do
    quote do: {unquote(name), unquote(type)}
  end

  defmacro arg(name, _opts \\ [], do: body) do
    args = fetch(body, @allowed_macros)

    quote do: {unquote(name), Enum.into(unquote(args), %{})}
  end
end
