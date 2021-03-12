defmodule GraphyTest do
  use ExUnit.Case

  defmodule Sample do
    use Graphy
  end

  test "generate query from structure" do
    assert Sample.query() == %{root: %{person: [name: nil]}}
  end
end
