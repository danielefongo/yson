defmodule Yson.Util.AttributesTest do
  use ExUnit.Case
  alias Yson.Util.Attributes

  defmodule Dummy, do: :ok

  describe "on single value" do
    test "set and get" do
      defmodule SingleSetAndGet do
        Yson.Util.Attributes.set(__MODULE__, :key, :value)
        Yson.Util.Attributes.set(__MODULE__, :key2, :value2)
      end

      assert Attributes.get(SingleSetAndGet, :key) == :value
      assert Attributes.get(SingleSetAndGet, :key2) == :value2
    end

    test "ovverride with set" do
      defmodule SingleSetOverride do
        Yson.Util.Attributes.set(__MODULE__, :key, :value)
        Yson.Util.Attributes.set(__MODULE__, :key, :new_value)
      end

      assert Attributes.get(SingleSetOverride, :key) == :new_value
    end

    test "set! and get!" do
      defmodule SingleSetAndGetBang do
        Yson.Util.Attributes.set!(__MODULE__, :key, :value)
        Yson.Util.Attributes.set!(__MODULE__, :key2, :value2)
      end

      assert Attributes.get!(SingleSetAndGetBang, :key) == :value
      assert Attributes.get!(SingleSetAndGetBang, :key2) == :value2
    end

    test "raise on duplicate set!" do
      assert_raise RuntimeError, fn ->
        defmodule SingleSetBangError do
          Yson.Util.Attributes.set!(__MODULE__, :key, :value)
          Yson.Util.Attributes.set!(__MODULE__, :key, :value2)
        end
      end
    end

    test "raise on get! and nil value" do
      assert_raise RuntimeError, fn ->
        Yson.Util.Attributes.get!(Dummy, :key)
      end
    end
  end

  describe "on keyword" do
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

    test "raise on duplicate set!" do
      assert_raise RuntimeError, fn ->
        defmodule SingleSetBangError do
          Yson.Util.Attributes.set!(__MODULE__, :map, :first, :value)
          Yson.Util.Attributes.set!(__MODULE__, :map, :first, :value2)
        end
      end
    end

    test "raise on get! and nil value" do
      assert_raise RuntimeError, fn ->
        Yson.Util.Attributes.get!(Dummy, :map, :key)
      end
    end
  end
end
