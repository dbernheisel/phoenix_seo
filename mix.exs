defmodule SEO.MixProject do
  use Mix.Project
  @version "0.1.0"

  def project do
    [
      app: :seo,
      version: @version,
      elixir: ">= 1.14.0",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [tests: :test],
      package: package(),
      homepage_url: "https://hexdocs.pm/seo",
      source_url: "https://github.com/dbernheisel/seo",
      description:
        "Framework for Phoenix applications to more-easily optimize your site for search engines and displaying rich results when your URLs are shared across the internet."
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "CHANGELOG*",
        "README*",
        "LICENSE*"
      ],
      maintainers: ["David Bernheisel"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/dbernheisel/seo",
        "Readme" => "https://github.com/dbernheisel/seo/blob/#{@version}/README.md",
        "Changelog" => "https://github.com/dbernheisel/seo/blob/#{@version}/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "SEO",
      assets: "assets",
      logo: "priv/logomark-small.png",
      source_ref: @version,
      extras: ["CHANGELOG.md", "LICENSE"]
    ]
  end

  defp aliases do
    [
      tests: ["format --check-formatted", "credo --strict", "test"]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 0.18"},
      # Dev / Test
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:makeup_eex, "~> 0.1", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.0", only: [:dev, :test]}
    ]
  end
end
