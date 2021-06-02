defmodule Support.Person do
  @moduledoc false
  use Yson.Schema
  alias __MODULE__

  import_schema(Support.Address)

  map :person, resolver: &Person.person/1 do
    reference(:natural_person)
    reference(:legal_person)
  end

  interface :legal_person do
    reference(:address)
    value(:company_name)
  end

  interface :natural_person do
    reference(:address)
    value(:first_name)
    value(:last_name)
  end

  def person(%{company_name: name}), do: %{full_name: name}
  def person(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
