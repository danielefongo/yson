defmodule Yson.Macro.Query do
  @moduledoc false
  import Yson.Util.AST
  alias Yson.Util.Attributes

  defmacro query(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :query, body)

  defmacro mutation(name, _opts \\ [], do: body),
    do: request(__CALLER__.module, name, :mutation, body)

  defp request(module, name, kind, body) do
    body = fetch(body, [:arg])

    quote do
      Attributes.set(unquote(module),
        kind: unquote(kind),
        object: unquote(name),
        arguments: unquote(body)
      )

      Enum.into(unquote(body), %{})
    end
  end

  def kind(module), do: Attributes.get(module, :kind)
  def object(module), do: Attributes.get(module, :object)
  def arguments(module), do: module |> Attributes.get(:arguments) |> Enum.into(%{})
end
