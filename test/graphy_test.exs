defmodule GraphyTest do
  use ExUnit.Case
  require Graphy
  import Graphy

  test "single field" do
    obj = field(:foo)
    assert obj == {:foo, nil}
  end

  test "composite field" do
    obj =
      field :foo do
        field(:foo)
      end

    assert obj == {:foo, %{foo: nil}}
  end

  test "interface" do
    obj =
      interface :foo do
        field(:foo)
      end

    assert obj == {:foo, [foo: nil]}
  end

  test "object" do
    obj =
      object :foo do
        field(:one)
        field(:two)
      end

    assert obj == %{one: nil, two: nil}
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
        end

        interface :natural_person do
          field(:first_name)
          field(:second_name)
        end

        interface :legal_person do
          field(:company_name)
        end
      end
    end

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
