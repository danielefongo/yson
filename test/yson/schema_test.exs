defmodule Yson.SchemaTest do
  use ExUnit.Case
  alias Yson.Macro.Reference

  defmodule Sample do
    use Yson.Schema

    map :foo do
      value(:one)
    end
  end

  defmodule Sample2 do
    use Yson.Schema.Json

    import_schema(Sample)

    root do
      reference(:foo)
    end

    map :bar do
      value(:one)
    end
  end

  test "extend references" do
    assert [bar: _, foo: _] = Reference.get_references(Sample2)
  end
end
