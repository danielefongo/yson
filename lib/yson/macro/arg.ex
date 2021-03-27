defmodule Yson.Macro.Arg do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Yson.Macro
      alias Yson.Macro.Arg
      require Arg

      @allowed_macros [:arg]

      defmacro arg(name, type) when is_atom(type) do
        quote do
          {unquote(name), unquote(type)}
        end
      end

      defmacro arg(name, _opts \\ [], do: body) do
        args = fetch(body, @allowed_macros)

        quote do
          {unquote(name), Enum.into(unquote(args), %{})}
        end
      end
    end
  end
end