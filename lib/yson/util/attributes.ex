defmodule Yson.Util.Attributes do
  @moduledoc false

  def set!(module, keywords) do
    Enum.each(keywords, fn {key, value} -> set!(module, key, value) end)
  end

  def set(module, keywords) do
    Enum.each(keywords, fn {key, value} -> set(module, key, value) end)
  end

  def set!(module, key, value) do
    case get(module, key) do
      nil -> set(module, key, value)
      _ -> raise "#{key} already defined."
    end
  end

  def set(module, key, value) do
    if not editable?(module) do
      raise "#{module} already compiled."
    end

    Module.register_attribute(module, key, persist: true)
    Module.put_attribute(module, key, value)

    value
  end

  def set!(module, key, sub_key, value) do
    case get(module, key, sub_key) do
      nil -> set(module, key, sub_key, value)
      _ -> raise "#{sub_key} already defined in #{key}."
    end
  end

  def set(module, key, sub_key, value) do
    if not editable?(module) do
      raise "#{module} already compiled"
    end

    Module.register_attribute(module, key, persist: true)
    data = Module.get_attribute(module, key, [])
    data = Keyword.put(data, sub_key, value)
    Module.put_attribute(module, key, data)

    value
  end

  def get!(module, key) do
    case get(module, key) do
      nil -> raise "#{key} not found."
      value -> value
    end
  end

  def get(module, key) do
    if editable?(module) do
      Module.get_attribute(module, key)
    else
      :attributes
      |> module.__info__()
      |> Keyword.get(key)
    end
  end

  def get!(module, key, sub_key) do
    case get(module, key, sub_key) do
      nil -> raise "#{sub_key} not found in #{key}."
      value -> value
    end
  end

  def get(module, key, sub_key) do
    module
    |> get(key)
    |> case do
      nil -> nil
      keywords -> Keyword.get(keywords, sub_key)
    end
  end

  defp editable?(module), do: :elixir_module.mode(module) == :all
end
