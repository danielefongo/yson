defmodule Graphy.Macro.Arg do
  @moduledoc false
  use Graphy.Macro

  defmacro __using__(_) do
    quote do
      use Graphy.Macro
      alias Graphy.Macro.Arg
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
