defmodule Yson.Util.Attributes do
  @moduledoc false

  def set(module, keywords) do
    Enum.each(keywords, fn {key, value} -> set(module, key, value) end)
  end

  def set(module, key, value) do
    if editable?(module) do
      Module.register_attribute(module, key, persist: true)
      Module.put_attribute(module, key, value)
    end

    value
  end

  def set(module, key, sub_key, value) do
    if editable?(module) do
      Module.register_attribute(module, key, persist: true)
      data = Module.get_attribute(module, key, [])
      data = Keyword.put(data, sub_key, value)
      Module.put_attribute(module, key, data)
    end

    value
  end

  def get(module, key) do
    if editable?(module) do
      Module.get_attribute(module, key, [])
    else
      Keyword.get(module.__info__(:attributes), key, [])
    end
  end

  def get(module, key, sub_key) do
    module
    |> get(key)
    |> Keyword.get(sub_key, [])
  end

  defp editable?(module), do: :elixir_module.mode(module) == :all
end
