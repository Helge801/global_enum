defmodule GlobalEnum.MixProject do
  use Mix.Project

  @version "0.0.1"
  @github_url "https://github.com/Helge801/global_enum"

  @description """
  Elixir Library for creating enums
  """

  def project do
    [
      aliases: aliases(),
      app: :global_enum,
      deps: deps(),
      description: @description,
      dialyzer: [plt_add_apps: [:ex_unit]],
      docs: docs(),
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "GlobalEnum",
      package: package(),
      preferred_cli_env: [check: :test],
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application do
    []
  end

  defp aliases do
    [
      check: ["format --check-formatted", "credo --strict", "test", "dialyzer"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6.0", only: [:dev, :test], runtime: false, optional: true},
      {:dialyxir, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      canonical: "http://hexdocs.pm/global_enum",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @github_url
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Bryan Lund"],
      contributors: ["Bryan Lund"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@github_url}/blob/master/CHANGELOG.md",
        "GitHub" => @github_url
      }
    ]
  end
end
