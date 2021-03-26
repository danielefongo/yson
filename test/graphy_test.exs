defmodule GraphyTest do
  use ExUnit.Case
  require Graphy
  import Graphy
  import Function, only: [identity: 1]

  def echo_resolver(e), do: e

  defmodule Sample do
    use Graphy

    query :sample do
      arg :user do
        arg(:email, :string)
        arg(:age, :integer)
      end
    end

    object :sample do
      ref(:user, :user)
      ref(:natural_person, :natural_person)

      interface :legal_person do
        value(:company_name)
      end

      map :data do
        value(:some_data)
      end
    end

    map :user, resolver: &Sample.user/1 do
      value(:email)
    end

    interface :natural_person do
      value(:first_name)
      value(:second_name)
    end

    def user(data), do: data
  end

  describe "on body" do
    test "value with default resolver" do
      data = value(:foo)
      assert data == [:field, :foo, &Function.identity/1]
    end

    test "value with custom resolver" do
      data = value(:foo, &Sample.user/1)
      assert data == [:field, :foo, &Sample.user/1]
    end

    test "reference" do
      data = ref(:foo, :another)
      assert data == [:ref, :foo, :another]
    end

    test "map with default resolver" do
      data =
        map :foo do
          value(:foo)
          value(:foo2)
        end

      assert data == [
               :map,
               false,
               :foo,
               &Function.identity/1,
               [
                 [:field, :foo, &Function.identity/1],
                 [:field, :foo2, &Function.identity/1]
               ]
             ]
    end

    test "map with custom resolver" do
      data =
        map :foo, resolver: &Sample.user/1 do
          value(:foo)
        end

      assert data == [
               :map,
               false,
               :foo,
               &Sample.user/1,
               [
                 [:field, :foo, &Function.identity/1]
               ]
             ]
    end

    test "nested map" do
      data =
        nested_map :foo do
          value(:foo)
          value(:foo2)
        end

      assert data == [
               :map,
               true,
               :foo,
               &Function.identity/1,
               [
                 [:field, :foo, &Function.identity/1],
                 [:field, :foo2, &Function.identity/1]
               ]
             ]
    end

    test "interface" do
      data =
        interface :foo do
          value(:foo)
        end

      assert data == [
               :interface,
               false,
               :foo,
               &Function.identity/1,
               [
                 [:field, :foo, &Function.identity/1]
               ]
             ]
    end

    test "nested interface" do
      data =
        nested_interface :foo do
          value(:foo)
        end

      assert data == [
               :interface,
               true,
               :foo,
               &Function.identity/1,
               [
                 [:field, :foo, &Function.identity/1]
               ]
             ]
    end

    test "object with default resolver" do
      data =
        object :foo do
          value(:one)
          value(:two)
        end

      assert data == [
               :map,
               false,
               :foo,
               &Function.identity/1,
               [[:field, :one, &Function.identity/1], [:field, :two, &Function.identity/1]]
             ]
    end

    test "object with custom resolver" do
      data =
        object :foo, resolver: &Sample.user/1 do
          value(:one)
        end

      assert data == [:map, false, :foo, &Sample.user/1, [[:field, :one, &Function.identity/1]]]
    end

    test "object with nested map" do
      data =
        object :foo do
          map :bar do
            value(:baz)
          end
        end

      assert data == [
               :map,
               false,
               :foo,
               &Function.identity/1,
               [[:map, true, :bar, &Function.identity/1, [[:field, :baz, &Function.identity/1]]]]
             ]
    end
  end

  test "single argument" do
    obj = arg(:foo, :string)

    assert obj == {:foo, :string}
  end

  test "composite argument" do
    obj =
      arg :foo do
        arg(:foo, :string)
      end

    assert obj == {:foo, %{foo: :string}}
  end

  test "query" do
    obj =
      query :sample do
        arg(:one, :string)
        arg(:two, :integer)
      end

    assert obj == %{one: :string, two: :integer}
  end

  test "mutation" do
    obj =
      mutation :sample do
        arg(:one, :string)
        arg(:two, :integer)
      end

    assert obj == %{one: :string, two: :integer}
  end

  test "generate description" do
    description = Sample.describe()

    assert description.object == :sample

    assert description.body == %{
             sample: %{
               user: %{email: nil},
               data: %{some_data: nil},
               natural_person: [
                 first_name: nil,
                 second_name: nil
               ],
               legal_person: [company_name: nil]
             }
           }

    assert description.arguments == %{
             user: %{
               email: :string,
               age: :integer
             }
           }
  end

  test "generate resolvers" do
    assert Sample.resolvers() == %{
             sample:
               {&identity/1,
                %{
                  company_name: &identity/1,
                  first_name: &identity/1,
                  second_name: &identity/1,
                  user: {&GraphyTest.Sample.user/1, %{email: &identity/1}},
                  data: {&identity/1, %{some_data: &identity/1}}
                }}
           }
  end
end
