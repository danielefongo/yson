defmodule Support.PersonClient do
  @moduledoc false
  use Graphy
  alias __MODULE__

  query do
    arg :user do
      arg(:email, :string)
    end
  end

  object :sample do
    field(:email)

    field :user do
      interface :natural_person do
        field(:first_name)
        field(:last_name)
      end

      interface :legal_person do
        field(:company_name)
      end

      resolver(&PersonClient.user/1)
    end
  end

  def user(%{company_name: name}), do: %{full_name: name}
  def user(%{first_name: name, last_name: surname}), do: %{full_name: "#{name} #{surname}"}
end
