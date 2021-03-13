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

  test "generate query" do
    defmodule Sample do
      use Graphy

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

    query = Sample.query()

    assert query.object == :sample

    assert query.body == %{
             user: %{email: nil},
             natural_person: [
               first_name: nil,
               second_name: nil
             ],
             legal_person: [company_name: nil]
           }
  end
end
