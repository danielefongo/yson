defmodule Support.PersonClient do
  @moduledoc false
  use Yson.GraphQL
  alias __MODULE__

  query :sample do
    arg :user do
      arg(:email, :string)
    end
  end

  map :sample do
    value(:email)
    reference(:user)
  end

  map :user, resolver: &PersonClient.user/1 do
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
