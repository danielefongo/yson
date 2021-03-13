defmodule GraphyTest do
  use ExUnit.Case

  defmodule Sample do
    use Graphy

    object :sample do
      field(:email)

      interface :natural_person do
        field(:first_name)
        field(:second_name)
      end

      interface :legal_person do
        field(:company_name)
      end
    end
  end

  test "generate query from structure" do
    assert Sample.query() == %{
             email: nil,
             natural_person: [
               first_name: nil,
               second_name: nil
             ],
             legal_person: [
               company_name: nil
             ]
           }
  end
end
