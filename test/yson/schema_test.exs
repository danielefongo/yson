defmodule Yson.SchemaTest do
  use ExUnit.Case
  import Yson.Schema
  import Function, only: [identity: 1]
  import Support.Macro

  describe "circular references" do
    test "raise error on self reference" do
      assert_raise RuntimeError, fn ->
        defmodule CircularReferenceSelf do
          use Yson.Schema

          map :foo do
            reference(:foo)
          end
        end
      end
    end

    test "raise error on cross reference" do
      assert_raise RuntimeError, fn ->
        defmodule CircularReferenceCross do
          use Yson.Schema

          map :foo do
            reference(:bar)
          end

          map :bar do
            reference(:foo)
          end
        end
      end
    end
  end

  describe "import schema" do
    test "references" do
      defmodule ReferencesBase do
        use Yson.Schema

        map :foo do
          value(:one)
        end
      end

      defmodule ReferencesExtended do
        use Yson.Schema

        import_schema(ReferencesBase)

        root do
          reference(:foo)
          value(:bar)
        end
      end

      assert [foo: _] = Attributes.get(ReferencesExtended, [:imported_references])
    end

    test "description" do
      defmodule ReferencesDescriptionBase do
        use Yson.Schema

        map :foo do
          value(:one)
        end
      end

      defmodule ReferencesDescriptionExtended do
        use Yson.Schema

        import_schema(ReferencesDescriptionBase)

        root do
          reference(:foo)
        end
      end

      assert describe(ReferencesDescriptionExtended) == %{foo: %{one: nil}}
    end

    test "don't propagate references" do
      defmodule PropagateBase do
        use Yson.Schema

        map :foo do
          value(:one)
        end
      end

      defmodule PropagateIntermediate do
        use Yson.Schema

        import_schema(PropagateBase)

        map :bar do
          value(:one)
        end
      end

      defmodule PropagateExtended do
        use Yson.Schema

        import_schema(PropagateIntermediate)
      end

      assert [bar: _] = Attributes.get(PropagateExtended, [:imported_references])
    end

    test "raise on conflicts" do
      assert_raise RuntimeError, fn ->
        defmodule RaiseBase do
          use Yson.Schema

          map :foo do
            value(:one)
          end
        end

        defmodule RaiseExtended do
          use Yson.Schema

          import_schema(RaiseBase)

          map :foo do
            value(:one)
          end
        end
      end
    end
  end

  describe "interface" do
    test "description" do
      defmodule InterfaceDescription do
        use Yson.Schema

        root do
          interface :foo do
            value(:one)
            value(:two)
          end
        end
      end

      assert describe(InterfaceDescription) == %{foo: [one: nil, two: nil]}
    end

    test "resolvers" do
      defmodule InterfaceResolvers do
        use Yson.Schema

        root do
          interface :foo do
            value(:one)
            value(:two)
          end
        end
      end

      {_, resolvers} = resolvers(InterfaceResolvers)

      assert resolvers == %{one: &identity/1, two: &identity/1}
    end

    test "references" do
      defmodule InterfaceReferences do
        use Yson.Schema

        interface :foo do
          value(:one)
          value(:two)
        end
      end

      assert [foo: _] = Attributes.get(InterfaceReferences, [:references])
    end
  end

  describe "nested interface" do
    test "description" do
      defmodule NestedInterfaceDescription do
        use Yson.Schema

        root do
          map :foo do
            interface :bar do
              value(:one)
              value(:two)
            end
          end
        end
      end

      assert describe(NestedInterfaceDescription) == %{foo: %{bar: [one: nil, two: nil]}}
    end

    test "resolvers" do
      defmodule NestedInterfaceResolvers do
        use Yson.Schema

        root do
          map :foo do
            interface :bar do
              value(:one)
              value(:two)
            end
          end
        end
      end

      {_, resolvers} = resolvers(NestedInterfaceResolvers)

      assert resolvers == %{foo: {&identity/1, %{one: &identity/1, two: &identity/1}}}
    end
  end

  describe "map" do
    test "description" do
      defmodule MapDescription do
        use Yson.Schema

        root do
          map :foo do
            value(:one)
            value(:two)
          end
        end
      end

      assert describe(MapDescription) == %{foo: %{one: nil, two: nil}}
    end

    test "resolvers" do
      defmodule MapResolvers do
        use Yson.Schema

        root do
          map :foo do
            value(:one)
            value(:two)
          end
        end
      end

      {_, resolvers} = resolvers(MapResolvers)

      assert resolvers == %{foo: {&identity/1, %{one: &identity/1, two: &identity/1}}}
    end

    test "custom resolvers" do
      defmodule MapCustomResolvers do
        use Yson.Schema

        root do
          map :foo, resolver: &echo_resolver/1 do
            value(:one)
            value(:two)
          end
        end
      end

      {_, resolvers} = resolvers(MapCustomResolvers)

      assert resolvers == %{foo: {&echo_resolver/1, %{one: &identity/1, two: &identity/1}}}
    end

    test "references" do
      defmodule MapReferences do
        use Yson.Schema

        map :foo do
          value(:one)
          value(:two)
        end
      end

      assert [foo: _] = Attributes.get(MapReferences, [:references])
    end
  end

  describe "nested map" do
    test "description" do
      defmodule NestedMapDescription do
        use Yson.Schema

        root do
          map :foo do
            map :bar do
              value(:one)
              value(:two)
            end
          end
        end
      end

      assert describe(NestedMapDescription) == %{foo: %{bar: %{one: nil, two: nil}}}
    end

    test "resolvers" do
      defmodule NestedMapResolvers do
        use Yson.Schema

        root do
          map :foo do
            map :bar do
              value(:one)
              value(:two)
            end
          end
        end
      end

      assert resolvers(NestedMapResolvers) ==
               {&identity/1,
                %{
                  foo: {&identity/1, %{bar: {&identity/1, %{one: &identity/1, two: &identity/1}}}}
                }}
    end
  end

  describe "reference" do
    test "description" do
      defmodule ReferenceDescription do
        use Yson.Schema

        root do
          reference(:foo)
        end

        map :foo do
          value(:one)
          value(:two)
        end
      end

      assert describe(ReferenceDescription) == %{foo: %{one: nil, two: nil}}
    end

    test "resolvers" do
      defmodule ReferenceResolvers do
        use Yson.Schema

        root do
          reference(:foo)
        end

        map :foo do
          value(:one)
          value(:two)
        end
      end

      assert resolvers(ReferenceResolvers) ==
               {&identity/1, %{foo: {&identity/1, %{one: &identity/1, two: &identity/1}}}}
    end
  end

  describe "root" do
    test "description" do
      defmodule RootDescription do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      assert describe(RootDescription) == %{foo: nil}
    end

    test "resolvers" do
      defmodule RootResolvers do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      assert resolvers(RootResolvers) == {&identity/1, %{foo: &identity/1}}
    end

    test "custom resolvers" do
      defmodule CustomRootResolvers do
        use Yson.Schema

        root resolver: &echo_resolver/1 do
          value(:foo)
        end
      end

      assert resolvers(CustomRootResolvers) == {&echo_resolver/1, %{foo: &identity/1}}
    end
  end

  describe "value" do
    test "description" do
      defmodule ValueDescription do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      assert describe(ValueDescription) == %{foo: nil}
    end

    test "resolvers" do
      defmodule ValueResolvers do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      assert resolvers(ValueResolvers) == {&identity/1, %{foo: &identity/1}}
    end

    test "custom resolvers" do
      defmodule ValueCustomResolvers do
        use Yson.Schema

        root do
          value(:foo, &echo_resolver/1)
        end
      end

      assert resolvers(ValueCustomResolvers) == {&identity/1, %{foo: &echo_resolver/1}}
    end
  end
end
