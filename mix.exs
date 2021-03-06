defmodule Yson.Builder.MixProject do
  use Mix.Project

  @github "https://github.com/danielefongo/yson"
  @version "0.2.2"

  def project do
    [
      app: :yson,
      description: "Run json/graphql requests and parse responses in an easy way",
      source_url: @github,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: [
        links: %{"GitHub" => @github},
        licenses: ["GPL-3.0-or-later"]
      ],
      docs: [
        main: "readme",
        extras: ["README.md", "changelog.md", "LICENSE"],
        source_ref: "v#{@version}",
        source_url: @github
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2.2"},
      {:recase, "~> 0.5"},
      {:ex_doc, "~> 0.24.2"},
      {:attributes, "~> 0.4.0"},
      {:absinthe, "~> 1.6", only: :test},
      {:bypass, "~> 2.1.0-rc.0", only: :test},
      {:credo, "~> 1.4.1", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp aliases do
    [
      "format.all": [
        "format mix.exs 'lib/**/*.{ex,exs}' 'test/**/*.{ex,exs}' 'config/*.{ex,exs}'"
      ],
      "format.check": [
        "format --check-formatted mix.exs 'lib/**/*.{ex,exs}' 'test/**/*.{ex,exs}' 'config/*.{ex, exs}'"
      ],
      check: [
        "compile --all-warnings --ignore-module-conflict --warnings-as-errors --debug-info",
        "format.check",
        "credo"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
