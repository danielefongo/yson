defmodule Support.Server do
  @moduledoc false

  use Absinthe.Schema

  @user %{
    email: "a@b.c",
    person: %{
      company_name: "legal name",
      address: %{
        city: "city",
        street: "street"
      }
    }
  }

  object :address do
    field(:city, :string)
    field(:street, :string)
  end

  interface :person do
    resolve_type(fn
      _, _ -> :legal_person
    end)
  end

  object :legal_person do
    field(:company_name, :string)
    field(:address, :address)
    interface(:person)
  end

  object :natural_person do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:address, :address)
    interface(:person)
  end

  object :user do
    field(:email, :string)
    field(:person, :person)
  end

  input_object :search do
    field(:email, non_null(:string))
  end

  query do
    field :user, type: :user do
      arg(:input, :search)

      resolve(fn _, _ -> {:ok, @user} end)
    end
  end
end
