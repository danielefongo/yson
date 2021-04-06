defmodule Support.PersonSchema do
  @moduledoc false
  use Yson.Schema
  alias __MODULE__

  map :user, resolver: &PersonSchema.user/1 do
    interface :natural_person do
      value(:first_name)
      value(:last_name)
    end

    reference(:legal_person)
  end

  interface :legal_person do
    value(:company_name)
  end

  def user(%{company_name: name}), do: %{full_name: name}
  def user(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
