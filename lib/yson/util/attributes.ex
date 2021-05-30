defmodule Yson.Util.Attributes do
  @moduledoc false
  @attributes_field :__attributes__

  def set!(module, key, value), do: set_on!(module, [key], value)
  def set(module, key, value), do: set_on(module, [key], value)

  def set!(module, key, sub_key, value), do: set_on!(module, [key, sub_key], value)
  def set(module, key, sub_key, value), do: set_on(module, [key, sub_key], value)

  def get!(module, key), do: get_from!(module, [key])
  def get(module, key), do: get_from(module, [key])

  def get!(module, key, sub_key), do: get_from!(module, [key, sub_key])
  def get(module, key, sub_key), do: get_from(module, [key, sub_key])

  defp editable?(module), do: :elixir_module.mode(module) == :all

  defp get_from!(module, where) do
    case get_from(module, where) do
      nil -> raise_err(where, "not found")
      value -> value
    end
  end

  defp get_from(module, where) do
    module
    |> attributes()
    |> get_in(filter(where))
  end

  defp set_on!(module, where, value) do
    case get_from(module, where) do
      nil -> set_on(module, where, value)
      _ -> raise_err(where, "already defined")
    end
  end

  defp set_on(module, where, value) do
    if not editable?(module) do
      raise "#{module} already compiled."
    end

    if is_nil(Module.get_attribute(module, @attributes_field)) do
      Module.register_attribute(module, @attributes_field, persist: true)
    end

    new_attributes =
      module
      |> attributes()
      |> put_in(filter(where), value)

    Module.put_attribute(module, @attributes_field, new_attributes)
  end

  defp attributes(module) do
    if editable?(module) do
      Module.get_attribute(module, @attributes_field, [])
    else
      :attributes
      |> module.__info__()
      |> Keyword.get(@attributes_field, [])
    end
  end

  def filter(where), do: Enum.flat_map(where, fn key -> [&handle_empty/3, key] end)

  def handle_empty(_, nil, next), do: next.([])
  def handle_empty(_, data, next), do: next.(data)

  defp raise_err(keys, message) do
    path = keys |> Enum.drop(-1) |> Enum.join(" -> ")
    key = List.last(keys)

    if path != "" do
      raise "#{key} #{message} in #{path}."
    else
      raise "#{key} #{message}."
    end
  end
end
