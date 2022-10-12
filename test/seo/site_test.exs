defmodule SEO.SiteTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  alias SEO.Site

  describe "meta" do
    test "renders everything" do
      default = %SEO.Site{
        title_suffix: "Suf",
        title_prefix: "Pre",
        canonical_url: "https://example.com/canonical",
        rating: "Adult",
        robots: ["noindex", "nofollow"],
        googlebot: "notranslate",
        alternate_languages: [
          {"en_US", "https://en.example.com"},
          {"ja_JP", URI.parse("https://jp.example.com")}
        ],
        google: ["nositelinkssearch", "nopagereadaloud"],
        description: "description"
      }

      item = %MyApp.Article{title: "Title"}

      result = render_component(&Site.meta/1, build_assigns(item, default))

      assert result =~ ~s|<title data-prefix="Pre" data-suffix="Suf">PreTitleSuf</title>|
      assert result =~ ~s|<link rel="canonical" href="https://example.com/canonical">|
      assert result =~ ~s|<link rel="alternate" hreflag="en_US" href="https://en.example.com">|
      assert result =~ ~s|<link rel="alternate" hreflag="ja_JP" href="https://jp.example.com">|
      assert result =~ ~s|<meta name="rating" content="Adult">|
      assert result =~ ~s|<meta name="robots" content="noindex, nofollow">|
      assert result =~ ~s|<meta name="google" content="nositelinkssearch, nopagereadaloud">|
      assert result =~ ~s|<meta name="googlebot" content="notranslate">|
    end

    test "renders a default title" do
      default = %SEO.Site{
        default_title: "Default Title",
        title_suffix: " · My App"
      }

      item = %MyApp.Article{title: nil}

      result = render_component(&Site.meta/1, build_assigns(item, default))

      assert result =~ ~s|<title data-suffix=" · My App">Default Title · My App</title>|
    end
  end

  defp build_assigns(item, default), do: [item: SEO.Build.site(item, default)]
end
