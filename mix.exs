defmodule SEO.MixProject do
  use Mix.Project
  @version "0.1.7"

  def project do
    [
      app: :phoenix_seo,
      name: "SEO",
      version: @version,
      elixir: ">= 1.14.0",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      homepage_url: "https://hexdocs.pm/phoenix_seo",
      source_url: "https://github.com/dbernheisel/phoenix_seo",
      preferred_cli_env: [tests: :test],
      package: package(),
      description:
        "Framework for Phoenix applications to optimize your site for search engines and displaying rich results when your URLs are shared across the internet."
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
      name: "phoenix_seo",
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
        "GitHub" => "https://github.com/dbernheisel/phoenix_seo",
        "Readme" => "https://github.com/dbernheisel/phoenix_seo/blob/#{@version}/README.md",
        "Changelog" => "https://github.com/dbernheisel/phoenix_seo/blob/#{@version}/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "SEO",
      assets: "assets",
      logo: "priv/logomark-small.png",
      source_ref: @version,
      groups_for_modules: groups_for_modules(),
      extras: ["CHANGELOG.md", "LICENSE"]
    ]
  end

  defp groups_for_modules do
    [
      Domains: [
        SEO.Breadcrumb,
        SEO.OpenGraph,
        SEO.Site,
        SEO.Twitter,
        SEO.Facebook,
        SEO.Unfurl
      ],
      "Open Graph": [
        SEO.OpenGraph.Article,
        SEO.OpenGraph.Audio,
        SEO.OpenGraph.Book,
        SEO.OpenGraph.Image,
        SEO.OpenGraph.Profile,
        SEO.OpenGraph.Video
      ],
      Breadcrumbs: [
        SEO.Breadcrumb.List,
        SEO.Breadcrumb.ListItem
      ],
      Protocol: [
        SEO.Breadcrumb.Build,
        SEO.OpenGraph.Build,
        SEO.Site.Build,
        SEO.Twitter.Build,
        SEO.Facebook.Build,
        SEO.Unfurl.Build
      ]
    ]
  end

  defp aliases do
    [
      tests: ["format --check-formatted", "credo --strict", "dialyzer", "test"]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 0.18"},
      # Dev / Test
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:jason, "~> 1.0", only: [:dev, :test]},
      {:makeup_eex, "~> 0.1", only: :dev, runtime: false}
    ]
  end
end
