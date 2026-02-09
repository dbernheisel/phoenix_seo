defmodule SEO.JsonLDTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  alias SEO.JsonLD
  alias SEO.JsonLD.{Article, Event, FAQ, LocalBusiness, Organization, Product}

  describe "meta" do
    test "renders a single JSON-LD item" do
      item = %{
        "@context" => "https://schema.org",
        "@type" => "Organization",
        "name" => "Acme Corp",
        "url" => "https://acme.com"
      }

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@context"] == "https://schema.org"
      assert ld["@type"] == "Organization"
      assert ld["name"] == "Acme Corp"
    end

    test "renders a list of JSON-LD items" do
      items = [
        %{"@context" => "https://schema.org", "@type" => "Organization", "name" => "Acme"},
        %{"@context" => "https://schema.org", "@type" => "WebSite", "name" => "Acme Site"}
      ]

      result = render_component(&JsonLD.meta/1, build_assigns(items))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert is_list(ld)
      assert length(ld) == 2
      assert Enum.at(ld, 0)["@type"] == "Organization"
      assert Enum.at(ld, 1)["@type"] == "WebSite"
    end

    test "doesn't render when item is nil" do
      result = render_component(&JsonLD.meta/1, build_assigns(nil))
      assert result == ""
    end

    test "doesn't render when item is empty list" do
      result = render_component(&JsonLD.meta/1, build_assigns([]))
      assert result == ""
    end

    test "doesn't render when item is empty map" do
      result = render_component(&JsonLD.meta/1, build_assigns(%{}))
      assert result == ""
    end

    test "renders item built from map with atom keys" do
      item = %{
        "@context": "https://schema.org",
        "@type": "Organization",
        name: "Acme Corp"
      }

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@type"] == "Organization"
      assert ld["name"] == "Acme Corp"
    end

    test "drops nil values from item" do
      item = %{
        "@context" => "https://schema.org",
        "@type" => "Organization",
        "name" => "Acme",
        "description" => nil
      }

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      refute Map.has_key?(ld, "description")
    end
  end

  describe "Article helper" do
    test "builds an Article with required fields" do
      item =
        Article.build(
          headline: "My Great Post",
          description: "A post about things",
          datePublished: ~D[2024-01-15]
        )

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@context"] == "https://schema.org"
      assert ld["@type"] == "Article"
      assert ld["headline"] == "My Great Post"
      assert ld["description"] == "A post about things"
      assert ld["datePublished"] == "2024-01-15"
    end

    test "builds an Article with all fields" do
      item =
        Article.build(
          headline: "My Post",
          description: "About things",
          datePublished: ~D[2024-01-15],
          dateModified: ~D[2024-02-01],
          author: %{"@type" => "Person", "name" => "Jane"},
          publisher: %{"@type" => "Organization", "name" => "Acme"},
          image: "https://example.com/img.jpg"
        )

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["author"] == %{"@type" => "Person", "name" => "Jane"}
      assert ld["publisher"] == %{"@type" => "Organization", "name" => "Acme"}
      assert ld["image"] == "https://example.com/img.jpg"
      assert ld["dateModified"] == "2024-02-01"
    end
  end

  describe "Organization helper" do
    test "builds an Organization" do
      item =
        Organization.build(
          name: "Acme Corp",
          url: "https://acme.com",
          logo: "https://acme.com/logo.png",
          sameAs: ["https://twitter.com/acme", "https://facebook.com/acme"]
        )

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@context"] == "https://schema.org"
      assert ld["@type"] == "Organization"
      assert ld["name"] == "Acme Corp"
      assert ld["url"] == "https://acme.com"
      assert ld["logo"] == "https://acme.com/logo.png"
      assert ld["sameAs"] == ["https://twitter.com/acme", "https://facebook.com/acme"]
    end
  end

  describe "FAQ helper" do
    test "builds a FAQPage from question/answer pairs" do
      item =
        FAQ.build([
          %{question: "What is Elixir?", answer: "A functional programming language."},
          %{question: "What is Phoenix?", answer: "A web framework for Elixir."}
        ])

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@context"] == "https://schema.org"
      assert ld["@type"] == "FAQPage"
      assert length(ld["mainEntity"]) == 2

      [q1, q2] = ld["mainEntity"]
      assert q1["@type"] == "Question"
      assert q1["name"] == "What is Elixir?"
      assert q1["acceptedAnswer"]["@type"] == "Answer"
      assert q1["acceptedAnswer"]["text"] == "A functional programming language."

      assert q2["name"] == "What is Phoenix?"
    end
  end

  describe "Product helper" do
    test "builds a Product" do
      item =
        Product.build(
          name: "Widget",
          description: "A great widget",
          image: "https://example.com/widget.jpg",
          brand: %{"@type" => "Brand", "name" => "Acme"},
          offers: %{
            "@type" => "Offer",
            "price" => "19.99",
            "priceCurrency" => "USD",
            "availability" => "https://schema.org/InStock"
          }
        )

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@type"] == "Product"
      assert ld["name"] == "Widget"
      assert ld["offers"]["price"] == "19.99"
      assert ld["brand"]["name"] == "Acme"
    end
  end

  describe "LocalBusiness helper" do
    test "builds a LocalBusiness" do
      item =
        LocalBusiness.build(
          name: "Joe's Pizza",
          address: %{
            "@type" => "PostalAddress",
            "streetAddress" => "123 Main St",
            "addressLocality" => "Springfield",
            "addressRegion" => "IL",
            "postalCode" => "62701"
          },
          telephone: "+1-555-555-5555",
          openingHoursSpecification: %{
            "@type" => "OpeningHoursSpecification",
            "dayOfWeek" => ["Monday", "Tuesday"],
            "opens" => "11:00",
            "closes" => "22:00"
          }
        )

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@type"] == "LocalBusiness"
      assert ld["name"] == "Joe's Pizza"
      assert ld["address"]["streetAddress"] == "123 Main St"
      assert ld["telephone"] == "+1-555-555-5555"
    end
  end

  describe "Event helper" do
    test "builds an Event" do
      item =
        Event.build(
          name: "ElixirConf 2024",
          startDate: ~D[2024-08-28],
          endDate: ~D[2024-08-30],
          location: %{
            "@type" => "Place",
            "name" => "Gaylord Rockies",
            "address" => "6700 N Gaylord Rockies Blvd"
          },
          description: "The Elixir conference"
        )

      result = render_component(&JsonLD.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)
      ld = linking_data(html)

      assert ld["@type"] == "Event"
      assert ld["name"] == "ElixirConf 2024"
      assert ld["startDate"] == "2024-08-28"
      assert ld["endDate"] == "2024-08-30"
      assert ld["location"]["name"] == "Gaylord Rockies"
    end
  end

  defp build_assigns(item) do
    [item: item, config: %{}, json_library: Jason]
  end

  defp linking_data(html) do
    case Floki.find(html, "script[type='application/ld+json']") do
      [{"script", _, json}] -> Jason.decode!(json)
      _ -> false
    end
  end
end
