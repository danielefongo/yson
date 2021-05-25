defmodule Yson.Util.Reference do
  alias Yson.Util.Attributes

  def set_references(module, data), do: Attributes.set(module, :references, data)
  def get_references(module), do: Attributes.get(module, :references)

  def set_reference(module, name, data) do
    if exists?(module, name), do: raise("Reference #{name} already defined.")
    Attributes.set(module, :references, name, data)
  end

  def get_reference(module, name) do
    if not exists?(module, name), do: raise("Reference #{name} not defined.")
    Attributes.get(module, :references, name)
  end

  defp exists?(module, name) do
    not is_nil(Attributes.get(module, :references, name))
  end
end
