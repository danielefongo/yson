defmodule Support.Address do
  @moduledoc false
  use Yson.Schema

  map :address do
    value(:city)
    value(:street)
  end
end
