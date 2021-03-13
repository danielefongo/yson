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
      field :user do
        field(:email)

        resolver(&Sample.user/1)
      end

      interface :natural_person do
        field(:first_name)
        field(:second_name)
      end

      interface :legal_person do
        field(:company_name)
      end
    end

    def user(data), do: data
  end

  describe "on body" do
    test "single field" do
      {obj, _resolvers} = field(:foo)
      assert obj == {:foo, nil}
    end

    test "composite field" do
      {obj, _resolvers} =
        field :foo do
          field(:foo)
          field(:foo2)
        end

      assert obj == {:foo, %{foo: nil, foo2: nil}}
    end

    test "interface" do
      {obj, _resolvers} =
        interface :foo do
          field(:foo)
        end

      assert obj == {:foo, [foo: nil]}
    end

    test "object" do
      {obj, _resolver} =
        object :foo do
          field(:one)
          field(:two)
        end

      assert obj == %{one: nil, two: nil}
    end
  end

  describe "on resolvers" do
    test "single field" do
      {_, resolvers} = field(:foo)
      assert resolvers == {:foo, &void_resolver/1}
    end

    test "composite field with default resolver" do
      {_, resolvers} =
        field :foo do
          field(:field)
        end

      assert resolvers == {
               :foo,
               {
                 &void_resolver/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "composite field with custom resolver" do
      {_, resolvers} =
        field :foo do
          field(:field)
          resolver(&echo_resolver/1)
        end

      assert resolvers == {
               :foo,
               {
                 &echo_resolver/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "ignore interfaces" do
      {_, resolvers} =
        field :foo do
          interface :foo do
            field(:field)
          end

          resolver(&echo_resolver/1)
        end

      assert resolvers == {
               :foo,
               {
                 &echo_resolver/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "object" do
      {_, resolvers} =
        object :foo do
          field(:field)
          resolver(&echo_resolver/1)
        end

      assert resolvers == %{
               foo: {
                 &echo_resolver/1,
                 %{field: &void_resolver/1}
               }
             }
    end

    test "object with default resolver" do
      {_, resolvers} =
        object :foo do
          field(:field)
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
end
