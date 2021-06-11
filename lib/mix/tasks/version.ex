defmodule Mix.Tasks.Version do
  @moduledoc false
  use Mix.Task

  def run(_), do: IO.puts(Mix.Project.config()[:version])
end
