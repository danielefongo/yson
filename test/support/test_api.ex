defmodule TestApi do
  @moduledoc false

  defmacro api_test(test_description, _opts \\ [], do: test_block) do
    quote do
      test unquote(test_description), %{bypass: var!(bypass)} do
        unquote(test_block)
      end
    end
  end

  defmacro mock(method, path, do: body) do
    quote do
      method_string = unquote(method) |> Atom.to_string() |> String.upcase()

      Bypass.expect(var!(bypass), method_string, unquote(path), fn var!(conn) ->
        unquote(body)
      end)
    end
  end

  defmacro response(status, value \\ "") do
    quote bind_quoted: [status: status, value: value] do
      response = if is_map(value), do: Jason.encode!(value), else: value
      Plug.Conn.resp(var!(conn), status, response)
    end
  end

  defmacro json_body do
    quote do
      {:ok, body, _conn} = Plug.Conn.read_body(var!(conn))
      Jason.decode!(body)
    end
  end

  defmacro __using__(_) do
    quote do
      import TestApi

      setup do
        bypass = Bypass.open(port: 55_000)
        {:ok, bypass: bypass}
      end
    end
  end
end
