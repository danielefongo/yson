defmodule Yson.Util.AttributesTest do
  use ExUnit.Case
  alias Yson.Util.Attributes

  defmodule Dummy, do: :ok

  test "set and get" do
    defmodule KeywordSetAndGet do
      Yson.Util.Attributes.set(__MODULE__, :map, :first, :value)
      Yson.Util.Attributes.set(__MODULE__, :map, :second, :value2)
    end

    assert Attributes.get(KeywordSetAndGet, :map) == [second: :value2, first: :value]
    assert Attributes.get(KeywordSetAndGet, :map, :first) == :value
    assert Attributes.get(KeywordSetAndGet, :map, :second) == :value2
  end

  test "ovverride with set" do
    defmodule KeywordSetOverride do
      Yson.Util.Attributes.set(__MODULE__, :map, :key, :value)
      Yson.Util.Attributes.set(__MODULE__, :map, :key, :new_value)
    end

    assert Attributes.get(KeywordSetOverride, :map, :key) == :new_value
  end

  test "set! and get!" do
    defmodule KeywordSetAndGetBang do
      Yson.Util.Attributes.set!(__MODULE__, :map, :first, :value)
      Yson.Util.Attributes.set!(__MODULE__, :map, :second, :value2)
    end

    assert Attributes.get(KeywordSetAndGetBang, :map) == [second: :value2, first: :value]
    assert Attributes.get(KeywordSetAndGetBang, :map, :first) == :value
    assert Attributes.get(KeywordSetAndGetBang, :map, :second) == :value2
  end
end
