defmodule GraphyTest do
  use ExUnit.Case

  defmodule Sample do
    use Graphy

    object :sample do
      field :root do
        interface :person do
          field(:name)
        end
      end
    end
  end

  test "generate query from structure" do
    assert Sample.query() == %{
             root: %{
               person: [name: nil]
             }
           }
  end
end
