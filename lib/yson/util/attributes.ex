defmodule Yson.Util.Attributes do
  @moduledoc false

  def set!(module, key, value), do: Attributes.set!(module, [key], value)
  def set(module, key, value), do: Attributes.set(module, [key], value)

  def set!(module, key, sub_key, value), do: Attributes.set!(module, [key, sub_key], value)
  def set(module, key, sub_key, value), do: Attributes.set(module, [key, sub_key], value)

  def get!(module, key), do: Attributes.get!(module, [key])
  def get(module, key), do: Attributes.get(module, [key])

  def get!(module, key, sub_key), do: Attributes.get!(module, [key, sub_key])
  def get(module, key, sub_key), do: Attributes.get(module, [key, sub_key])
end
