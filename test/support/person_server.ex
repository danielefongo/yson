defmodule Support.PersonServer do
  @moduledoc false

  use Absinthe.Schema

  @person %{
    email: "a@b.c",
    user: %{
      company_name: "legal name"
    }
  }

  interface :person do
    resolve_type(fn
      _, _ -> :legal_person
    end)
  end

  object :legal_person do
    field(:company_name, :string)
    interface(:person)
  end

  object :natural_person do
    field(:first_name, :string)
    field(:last_name, :string)
    interface(:person)
  end

  object :sample do
    field(:email, :string)
    field(:user, :person)
  end

  input_object :search do
    field(:email, non_null(:string))
  end

  query do
    field :sample, type: :sample do
      arg(:user, :search)

      resolve(fn _, _ -> {:ok, @person} end)
    end
  end
end
