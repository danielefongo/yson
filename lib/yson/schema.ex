defmodule Yson.Schema do
  @moduledoc false
  alias Yson.Macro.Reference
  alias Yson.Util.Merge

  defmacro __using__(_) do
    quote do
      require Yson.Schema
      import Yson.Schema

      require Yson.Macro.{Arg, Interface, Map, Reference, Value}
      import Yson.Macro.{Arg, Interface, Map, Reference, Value}
    end
  end

  defmacro import_schema(module_from) do
    module_to = __CALLER__.module

    quote do
      require unquote(module_from)
      first_data = Reference.get_references(unquote(module_from))
      second_data = Reference.get_references(unquote(module_to))

      Reference.set_references(unquote(module_to), Merge.merge(first_data, second_data))
    end
  end
end
