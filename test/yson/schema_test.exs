defmodule Yson.SchemaTest do
  use ExUnit.Case
  import Yson.Schema

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
      end

      assert [foo: _] = Attributes.get(ReferencesExtended, [:imported_references])
    end

    test "multiple references" do
      defmodule MultipleReferencesBase1 do
        use Yson.Schema

        map :foo do
          value(:one)
        end
      end

      defmodule MultipleReferencesBase2 do
        use Yson.Schema

        map :bar do
          value(:one)
        end
      end

      defmodule MultipleReferencesExtended do
        use Yson.Schema

        import_schema(MultipleReferencesBase1)
        import_schema(MultipleReferencesBase2)
      end

      assert [foo: _, bar: _] = Attributes.get(MultipleReferencesExtended, [:imported_references])
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

      assert describe(ReferencesDescriptionExtended) == [foo: [:one]]
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

      assert describe(InterfaceDescription) == [foo: {[:one, :two]}]
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

      expected_resolver = {InterfaceResolvers, :resolver_0}

      {^expected_resolver, [one: ^expected_resolver, two: ^expected_resolver]} =
        resolvers(InterfaceResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
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

      assert describe(NestedInterfaceDescription) == [foo: [bar: {[:one, :two]}]]
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

      expected_resolver = {NestedInterfaceResolvers, :resolver_0}

      {^expected_resolver,
       [foo: {^expected_resolver, [one: ^expected_resolver, two: ^expected_resolver]}]} =
        resolvers(NestedInterfaceResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
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

      assert describe(MapDescription) == [foo: [:one, :two]]
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

      expected_resolver = {MapResolvers, :resolver_0}

      {^expected_resolver,
       [foo: {^expected_resolver, [one: ^expected_resolver, two: ^expected_resolver]}]} =
        resolvers(MapResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
    end

    test "custom resolvers" do
      defmodule MapCustomResolvers do
        use Yson.Schema

        root do
          map :foo, resolver: fn _ -> send(self(), "map custom") end do
            value(:one)
            value(:two)
          end
        end
      end

      {_, [foo: {resolver, _}]} = resolvers(MapCustomResolvers)

      assert_resolver(resolver, "map custom")
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

      assert describe(NestedMapDescription) == [foo: [bar: [:one, :two]]]
    end

    test "resolvers" do
      defmodule NestedMapResolvers do
        use Yson.Schema

        root do
          map :foo do
            map :bar do
              value(:one)
            end
          end
        end
      end

      expected_resolver = {NestedMapResolvers, :resolver_0}

      {^expected_resolver,
       [
         foo: {^expected_resolver, [bar: {^expected_resolver, [one: ^expected_resolver]}]}
       ]} = resolvers(NestedMapResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
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

      assert describe(ReferenceDescription) == [foo: [:one, :two]]
    end

    test "description when aliased" do
      defmodule ReferenceAliasDescription do
        use Yson.Schema

        root do
          reference(:foo, as: :bar)
        end

        map :foo do
          value(:one)
        end
      end

      assert describe(ReferenceAliasDescription) == [bar: [:one]]
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

      expected_resolver = {ReferenceResolvers, :resolver_0}

      assert {^expected_resolver,
              [foo: {^expected_resolver, [one: ^expected_resolver, two: ^expected_resolver]}]} =
               resolvers(ReferenceResolvers)
    end

    test "resolvers when aliased" do
      defmodule ReferenceAliasResolvers do
        use Yson.Schema

        root do
          reference(:foo, as: :bar)
        end

        map :foo do
          value(:one)
        end
      end

      expected_resolver = {ReferenceAliasResolvers, :resolver_0}

      {^expected_resolver, [bar: {^expected_resolver, [one: ^expected_resolver]}]} =
        resolvers(ReferenceAliasResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
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

      assert describe(RootDescription) == [:foo]
    end

    test "resolvers" do
      defmodule RootResolvers do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      expected_resolver = {RootResolvers, :resolver_0}

      {^expected_resolver, [foo: _]} = resolvers(RootResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
    end

    test "custom resolvers" do
      defmodule CustomRootResolvers do
        use Yson.Schema

        root resolver: fn _ -> send(self(), "root custom") end do
          value(:foo)
        end
      end

      {resolver, [foo: _]} = resolvers(CustomRootResolvers)

      assert_resolver(resolver, "root custom")
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

      assert describe(ValueDescription) == [:foo]
    end

    test "resolvers" do
      defmodule ValueResolvers do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      expected_resolver = {ValueResolvers, :resolver_0}

      {_, [foo: ^expected_resolver]} = resolvers(ValueResolvers)

      assert execute_resolver(expected_resolver, :any) == :any
    end

    test "custom resolvers" do
      defmodule ValueCustomResolvers do
        use Yson.Schema

        root do
          value(:foo, fn _ -> send(self(), "value custom") end)
        end
      end

      {_, [foo: resolver]} = resolvers(ValueCustomResolvers)

      assert_resolver(resolver, "value custom")
    end
  end

  describe "resolvers" do
    test "default is identity" do
      defmodule ResolverIdentity do
        use Yson.Schema

        root do
          value(:foo)
        end
      end

      resolver = {ResolverIdentity, :resolver_0}

      {^resolver, _} = resolvers(ResolverIdentity)
    end

    test "private function" do
      defmodule ResolverPrivateFunction do
        use Yson.Schema

        root resolver: &private/1 do
          value(:foo)
        end

        defp private(_), do: :private
      end

      {resolver, _} = resolvers(ResolverPrivateFunction)

      assert execute_resolver(resolver, :any) == :private
    end

    test "anonymous function" do
      defmodule ResolverAnonymousFunction do
        use Yson.Schema

        root resolver: & &1 do
          value(:foo)
        end
      end

      {resolver, _} = resolvers(ResolverAnonymousFunction)

      assert execute_resolver(resolver, :any) == :any
    end

    test "increase counter on different resolver" do
      defmodule ResolverDifferentResolverCount do
        use Yson.Schema

        root do
          value(:foo, & &1)
        end
      end

      assert {{ResolverDifferentResolverCount, :resolver_0},
              [foo: {ResolverDifferentResolverCount, :resolver_1}]} =
               resolvers(ResolverDifferentResolverCount)
    end

    test "same resolvers do not generate different functions" do
      defmodule ResolverSameFunctions do
        use Yson.Schema

        root resolver: & &1 do
          value(:foo, & &1)
        end
      end

      resolver = {ResolverSameFunctions, :resolver_0}

      assert {^resolver, [foo: ^resolver]} = resolvers(ResolverSameFunctions)
    end

    test "same resolvers do not generate different complex functions" do
      defmodule ResolverSameComplexFunctions do
        use Yson.Schema

        root resolver: fn a ->
               Function.identity(a)
             end do
          value(:foo, fn a -> Function.identity(a) end)
        end
      end

      resolver = {ResolverSameComplexFunctions, :resolver_0}

      assert {^resolver, [foo: ^resolver]} = resolvers(ResolverSameComplexFunctions)
    end

    test "import schema" do
      defmodule ResolverSchemaBase do
        use Yson.Schema

        map :foo, resolver: & &1 do
          value(:bar)
        end
      end

      defmodule ResolverSchemaExtended do
        use Yson.Schema

        import_schema(ResolverSchemaBase)

        root do
          reference(:foo)
        end
      end

      assert {{ResolverSchemaExtended, :resolver_0},
              [foo: {{ResolverSchemaBase, :resolver_0}, _}]} = resolvers(ResolverSchemaExtended)
    end
  end

  defp execute_resolver({module, fun}, value), do: apply(module, fun, [value])

  defp assert_resolver(resolver, expected_value) do
    execute_resolver(resolver, [:any])
    assert_received ^expected_value
  end
end
