defmodule Support.User do
  @moduledoc false
  use Yson.Schema
  alias __MODULE__

  import_schema(Support.Person)

  map :user, resolver: &User.user/1 do
    reference(:natural_person)
    reference(:legal_person)
  end

  def user(%{company_name: name}), do: %{full_name: name}
  def user(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
