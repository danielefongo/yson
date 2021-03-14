defmodule Graphy.MapUtilTest do
  use ExUnit.Case
  alias Graphy.MapUtil

  describe "on subset" do
    test "return filtered map" do
      map = %{a: 1, b: 2}
      expected_map = %{a: 1}

      assert MapUtil.subset(map, [:a]) == expected_map
    end

    test "return same map when all the keys are provided" do
      map = %{a: 1, b: 2}

      assert MapUtil.subset(map, [:a, :b]) == map
    end
  end

  describe "on has_keys" do
    test "return true if has all the keys" do
      map = %{a: 1, b: 2}

      assert MapUtil.has_keys?(map, [:a]) == true
    end

    test "return false when some keys are missing" do
      map = %{a: 1, b: 2}

      assert MapUtil.has_keys?(map, [:a, :b, :c]) == false
    end
  end

  describe "on flatten" do
    test "return same map when already shallow" do
      map = %{a: 1, b: 2}

      assert MapUtil.flatten(map) == map
    end

    test "return flattened map when some properties are nested" do
      map = %{a: 1, map: %{b: 2}}
      expected_map = %{a: 1, b: 2}

      assert MapUtil.flatten(map) == expected_map
    end
  end
end
