defmodule Support.Person do
  @moduledoc false
  use Yson.Schema

  interface :legal_person do
    value(:company_name)
  end

  interface :natural_person do
    value(:first_name)
    value(:last_name)
  end
end
