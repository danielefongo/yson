defmodule Example do
  defstruct [:name, :age, :phone]

  @type t() :: %__MODULE__{
      name: String.t(),
      age: integer(),
      phone: String.t()
    }
end
