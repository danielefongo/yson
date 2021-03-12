defmodule Graphy do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def query, do: %{root: %{person: [name: nil]}}
    end
  end
end
