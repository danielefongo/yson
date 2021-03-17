defmodule GraphyTest do
  use ExUnit.Case
  require Graphy
  import Graphy

  def echo_resolver(e), do: e

  defmodule Sample do
    use Graphy

    query do
      arg :user do
        arg(:email, :string)
        arg(:age, :integer)
      end
    end

    object :sample do
      map :user, resolver: &Sample.user/1 do
        value(:email)
      end

      interface :natural_person do
        value(:first_name)
        value(:second_name)
      end

      interface :legal_person do
        value(:company_name)
      end
    end

    def user(data), do: data
  end

  describe "on body" do
    test "value" do
      {obj, _resolvers} = value(:foo)
      assert obj == {:foo, nil}
    end

    test "map" do
      {obj, _resolvers} =
        map :foo do
          value(:foo)
          value(:foo2)
        end

      assert obj == {:foo, %{foo: nil, foo2: nil}}
    end

    test "interface" do
      {obj, _resolvers} =
        interface :foo do
          value(:foo)
        end

      assert obj == {:foo, [foo: nil]}
    end

    test "object" do
      {obj, _resolver} =
        object :foo do
          value(:one)
          value(:two)
        end

      assert obj == %{one: nil, two: nil}
    end
  end

  describe "on resolvers" do
    test "value with default resolver" do
      {_, resolvers} = value(:foo)
      assert resolvers == {:foo, &void_resolver/1}
    end

    test "value with custom resolver" do
      {_, resolvers} = value(:foo, &Sample.user/1)
      assert resolvers == {:foo, &Sample.user/1}
    end

    test "map with default resolver" do
      {_, resolvers} =
        map :foo do
          value(:field)
        end

      assert resolvers == {
               :foo,
               {
                 &void_resolver/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "map with custom resolver" do
      {_, resolvers} =
        map :foo, resolver: &Sample.user/1 do
          value(:field)
        end

      assert resolvers == {
               :foo,
               {
                 &Sample.user/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "ignore interfaces" do
      {_, resolvers} =
        map :foo, resolver: &Sample.user/1 do
          interface :foo do
            value(:field)
          end
        end

      assert resolvers == {
               :foo,
               {
                 &Sample.user/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "object" do
      {_, resolvers} =
        object :foo, resolver: &Sample.user/1 do
          value(:field)
        end

      assert resolvers == %{
               foo: {
                 &Sample.user/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "object with default resolver" do
      {_, resolvers} =
        object :foo do
          value(:field)
        end

      assert resolvers == %{
               foo: {
                 &void_resolver/1,
                 %{field: &void_resolver/1}
               }
             }
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
      query do
        arg(:one, :string)
        arg(:two, :integer)
      end

    assert obj == %{one: :string, two: :integer}
  end

  test "mutation" do
    obj =
      mutation do
        arg(:one, :string)
        arg(:two, :integer)
      end

    assert obj == %{one: :string, two: :integer}
  end

  test "generate query" do
    description = Sample.describe()

    assert description.object == :sample

    assert description.body == %{
             user: %{email: nil},
             natural_person: [
               first_name: nil,
               second_name: nil
             ],
             legal_person: [company_name: nil]
           }

    assert description.arguments == %{
             user: %{
               email: :string,
               age: :integer
             }
           }
  end

  test "generate resolvers" do
    resolvers = Sample.resolvers()

    assert resolvers == %{
             sample:
               {&Graphy.void_resolver/1,
                %{
                  company_name: &Graphy.void_resolver/1,
                  first_name: &Graphy.void_resolver/1,
                  second_name: &Graphy.void_resolver/1,
                  user: {&GraphyTest.Sample.user/1, %{email: &Graphy.void_resolver/1}}
                }}
           }
  end
end
