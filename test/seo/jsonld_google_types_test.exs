defmodule SEO.JSONLDGoogleTypesTest do
  @moduledoc """
  Exhaustive tests for the Schema.org types Google has rich-result guides
  for. Each type gets:

    * a test that evaluates its curated example file and asserts the shape
      of the rendered JSON-LD map (verifies the example stays working after
      schema/generator changes)
    * at least one test exercising non-trivial fields — enum atom
      conversions, Date/DateTime/Duration struct handling, URI coercion,
      nested-builder composition — so that regressions in the conversion
      pipeline or in the type's own field set surface quickly.
  """
  use ExUnit.Case, async: true

  defp eval_example(filename) do
    {result, _bindings} = Code.eval_file("priv/examples/jsonld/#{filename}")
    result
  end

  defp assert_jsonld(result, type_name) do
    # `@context` is intentionally absent from `build/1` output — it's added
    # at render time by `SEO.JSONLD.meta/1` on the top-level node only.
    refute Map.has_key?(result, "@context")
    assert type_name in List.wrap(result["@type"])
  end

  describe "Article" do
    test "example renders headline/author/publisher with converted date" do
      result = eval_example("article.exs")

      assert_jsonld(result, "Article")
      assert result["headline"] == "How Elixir Crushed the Naysayers"
      assert result["datePublished"] == "2024-01-15"
      assert %{"@type" => "Person", "name" => "Jane Doe"} = result["author"]
      assert %{"@type" => "Organization", "name" => "Acme"} = result["publisher"]
      assert result["image"] == "https://example.com/hero.jpg"
    end

    test "supports full range of optional fields" do
      result =
        SEO.JSONLD.Article.build(%{
          headline: "Title",
          description: "Desc",
          date_published: ~D[2024-01-15],
          date_modified: ~U[2024-02-01 10:00:00Z],
          article_section: "Tech",
          article_body: "Body",
          word_count: 800,
          keywords: ["elixir", "beam"],
          in_language: "en-US",
          is_accessible_for_free: true,
          url: URI.parse("https://example.com/post")
        })

      assert result["datePublished"] == "2024-01-15"
      assert result["dateModified"] == "2024-02-01T10:00:00Z"
      assert result["articleSection"] == "Tech"
      assert result["wordCount"] == 800
      assert result["keywords"] == ["elixir", "beam"]
      assert result["inLanguage"] == "en-US"
      assert result["isAccessibleForFree"] == true
      assert result["url"] == "https://example.com/post"
    end
  end

  describe "BreadcrumbList" do
    test "example renders an ordered list of ListItems" do
      result = eval_example("breadcrumb_list.exs")

      assert_jsonld(result, "BreadcrumbList")
      assert [first, second] = result["itemListElement"]
      assert first["@type"] == "ListItem"
      assert first["position"] == 1
      assert first["name"] == "Home"
      assert second["position"] == 2
      assert second["name"] == "Blog"
    end
  end

  describe "Course" do
    test "accepts provider as a nested Organization and course metadata" do
      result =
        SEO.JSONLD.Course.build(%{
          name: "Elixir Fundamentals",
          description: "Introductory course",
          provider:
            SEO.JSONLD.Organization.build(%{name: "Academy", same_as: "https://academy.dev"})
        })

      assert_jsonld(result, "Course")
      assert result["name"] == "Elixir Fundamentals"
      assert %{"@type" => "Organization", "name" => "Academy"} = result["provider"]
    end
  end

  describe "Dataset" do
    test "accepts keywords, license, and creator" do
      result =
        SEO.JSONLD.Dataset.build(%{
          name: "NYC Taxi Trips",
          description: "A large dataset of taxi trips.",
          keywords: ["taxi", "NYC"],
          license: "https://creativecommons.org/licenses/by/4.0/",
          creator: SEO.JSONLD.Organization.build(%{name: "NYC TLC"}),
          url: URI.parse("https://example.com/taxi")
        })

      assert_jsonld(result, "Dataset")
      assert result["keywords"] == ["taxi", "NYC"]
      assert result["url"] == "https://example.com/taxi"
      assert %{"name" => "NYC TLC"} = result["creator"]
    end
  end

  describe "DiscussionForumPosting" do
    test "accepts author, text, date and comment thread" do
      result =
        SEO.JSONLD.DiscussionForumPosting.build(%{
          headline: "Opinion on OTP",
          text: "I really like supervision trees.",
          date_published: ~U[2024-03-01 10:00:00Z],
          author: SEO.JSONLD.Person.build(%{name: "Jane"}),
          comment: [
            SEO.JSONLD.Comment.build(%{
              text: "Agreed!",
              author: SEO.JSONLD.Person.build(%{name: "John"})
            })
          ]
        })

      assert_jsonld(result, "DiscussionForumPosting")
      assert result["datePublished"] == "2024-03-01T10:00:00Z"
      assert [%{"@type" => "Comment", "text" => "Agreed!"}] = result["comment"]
    end
  end

  describe "EmployerAggregateRating" do
    test "rates a hiring organization" do
      result =
        SEO.JSONLD.EmployerAggregateRating.build(%{
          item_reviewed: SEO.JSONLD.Organization.build(%{name: "Acme"}),
          rating_value: 4.3,
          rating_count: 178,
          best_rating: 5
        })

      assert_jsonld(result, "EmployerAggregateRating")
      assert result["ratingValue"] == 4.3
      assert result["ratingCount"] == 178
      assert %{"@type" => "Organization"} = result["itemReviewed"]
    end
  end

  describe "Event" do
    test "example converts dates, enum atoms, and nests a Place" do
      result = eval_example("event.exs")

      assert_jsonld(result, "Event")
      assert result["startDate"] == "2024-08-28"
      assert result["endDate"] == "2024-08-30"
      assert result["eventStatus"] == "https://schema.org/EventScheduled"
      assert result["eventAttendanceMode"] == "https://schema.org/OfflineEventAttendanceMode"
      assert %{"@type" => "Place", "name" => "Gaylord Rockies"} = result["location"]
      assert result["location"]["address"]["streetAddress"] == "6700 N Gaylord Rockies Blvd"
    end

    test "enum atom round-trips all EventStatus variants" do
      for atom <- [
            :event_scheduled,
            :event_cancelled,
            :event_postponed,
            :event_rescheduled,
            :event_moved_online
          ] do
        label = atom |> Atom.to_string() |> Macro.camelize()
        result = SEO.JSONLD.Event.build(%{name: "E", event_status: atom})
        assert result["eventStatus"] == "https://schema.org/#{label}"
      end
    end

    test "raises for unknown enum atom on event_status" do
      assert_raise KeyError, fn ->
        SEO.JSONLD.Event.build(%{name: "E", event_status: :not_a_valid_status})
      end
    end
  end

  describe "FAQPage" do
    test "example nests Question/Answer under main_entity" do
      result = eval_example("faq_page.exs")

      assert_jsonld(result, "FAQPage")
      assert [q1, q2] = result["mainEntity"]
      assert q1["@type"] == "Question"
      assert q1["name"] == "What is Elixir?"
      assert q1["acceptedAnswer"]["@type"] == "Answer"
      assert q1["acceptedAnswer"]["text"] == "A functional programming language."
      assert q2["name"] == "What is Phoenix?"
    end
  end

  describe "ImageObject" do
    test "accepts dimensions, creator, license, and exif data" do
      result =
        SEO.JSONLD.ImageObject.build(%{
          content_url: URI.parse("https://example.com/hero.jpg"),
          caption: "Entry hall",
          width: 1920,
          height: 1080,
          creator: SEO.JSONLD.Person.build(%{name: "Jane"}),
          license: "https://creativecommons.org/licenses/by/4.0/",
          credit_text: "Photo by Jane",
          copyright_notice: "(C) 2024 Acme"
        })

      assert_jsonld(result, "ImageObject")
      assert result["contentUrl"] == "https://example.com/hero.jpg"
      assert result["width"] == 1920
      assert result["height"] == 1080
      assert result["creditText"] == "Photo by Jane"
      assert result["copyrightNotice"] == "(C) 2024 Acme"
    end
  end

  describe "JobPosting" do
    test "example pulls together Org, Place, and MonetaryAmount" do
      result = eval_example("job_posting.exs")

      assert_jsonld(result, "JobPosting")
      assert result["title"] == "Senior Elixir Engineer"
      assert result["datePosted"] == "2024-03-01"
      assert result["validThrough"] == "2024-06-01"
      assert result["employmentType"] == "FULL_TIME"
      assert result["hiringOrganization"]["name"] == "Acme"
      assert result["jobLocation"]["address"]["streetAddress"] == "1600 Amphitheatre Pkwy"

      assert %{"@type" => "MonetaryAmount", "currency" => "USD"} = result["baseSalary"]
      assert result["baseSalary"]["value"]["value"] == 175_000
      assert result["baseSalary"]["value"]["unitText"] == "YEAR"
    end

    test "supports applicant requirements and direct apply flag" do
      result =
        SEO.JSONLD.JobPosting.build(%{
          title: "Remote Engineer",
          description: "Work from anywhere",
          date_posted: ~D[2024-03-01],
          hiring_organization: SEO.JSONLD.Organization.build(%{name: "Acme"}),
          applicant_location_requirements: SEO.JSONLD.Country.build(%{name: "USA"}),
          direct_apply: true
        })

      assert %{"@type" => "Country", "name" => "USA"} = result["applicantLocationRequirements"]
      assert result["directApply"] == true
    end
  end

  describe "LocalBusiness" do
    test "example renders address and geo" do
      result = eval_example("local_business.exs")

      assert_jsonld(result, "LocalBusiness")
      assert result["telephone"] == "+1-555-555-5555"
      assert result["priceRange"] == "$$"
      assert result["address"]["@type"] == "PostalAddress"
      assert result["address"]["streetAddress"] == "123 Main St"
      assert result["geo"]["@type"] == "GeoCoordinates"
      assert result["geo"]["latitude"] == 39.7817
    end

    test "accepts opening hours spec and price range" do
      result =
        SEO.JSONLD.LocalBusiness.build(%{
          name: "Store",
          address: SEO.JSONLD.PostalAddress.build(%{street_address: "1 Main"}),
          opening_hours_specification:
            SEO.JSONLD.OpeningHoursSpecification.build(%{
              day_of_week: :monday,
              opens: ~T[09:00:00],
              closes: ~T[17:00:00]
            })
        })

      spec = result["openingHoursSpecification"]
      assert spec["dayOfWeek"] == "https://schema.org/Monday"
      assert spec["opens"] == "09:00:00"
      assert spec["closes"] == "17:00:00"
    end
  end

  describe "MathSolver" do
    test "accepts name/url and access conditions" do
      result =
        SEO.JSONLD.MathSolver.build(%{
          name: "Step-by-step algebra solver",
          url: URI.parse("https://example.com/math"),
          conditions_of_access: "Free for educational use",
          in_language: "en"
        })

      assert_jsonld(result, "MathSolver")
      assert result["url"] == "https://example.com/math"
      assert result["conditionsOfAccess"] == "Free for educational use"
      assert result["inLanguage"] == "en"
    end
  end

  describe "Movie" do
    test "accepts director, actor list, and genre" do
      result =
        SEO.JSONLD.Movie.build(%{
          name: "Elixir: The Movie",
          image: "https://example.com/poster.jpg",
          director: SEO.JSONLD.Person.build(%{name: "Jose Valim"}),
          actor: [
            SEO.JSONLD.Person.build(%{name: "Alice"}),
            SEO.JSONLD.Person.build(%{name: "Bob"})
          ],
          genre: "Documentary",
          date_created: ~D[2024-01-01],
          duration: Duration.new!(minute: 118)
        })

      assert_jsonld(result, "Movie")
      assert %{"@type" => "Person", "name" => "Jose Valim"} = result["director"]
      assert length(result["actor"]) == 2
      assert result["dateCreated"] == "2024-01-01"
      assert result["duration"] == "PT118M"
    end
  end

  describe "Organization" do
    test "example renders nested ContactPoint" do
      result = eval_example("organization.exs")

      assert_jsonld(result, "Organization")
      assert result["url"] == "https://acme.com"
      assert result["sameAs"] == ["https://twitter.com/acme", "https://github.com/acme"]
      assert result["contactPoint"]["contactType"] == "customer service"
    end

    test "accepts founded date and address" do
      result =
        SEO.JSONLD.Organization.build(%{
          name: "Acme",
          founding_date: ~D[1999-12-31],
          address:
            SEO.JSONLD.PostalAddress.build(%{street_address: "1 HQ", address_locality: "SF"}),
          email: "hello@acme.com",
          legal_name: "Acme LLC"
        })

      assert result["foundingDate"] == "1999-12-31"
      assert result["legalName"] == "Acme LLC"
      assert result["address"]["streetAddress"] == "1 HQ"
    end
  end

  describe "Product" do
    test "example converts enum availability to URL" do
      result = eval_example("product.exs")

      assert_jsonld(result, "Product")
      assert result["offers"]["availability"] == "https://schema.org/InStock"
      assert result["offers"]["price"] == "19.99"
      assert result["aggregateRating"]["ratingValue"] == 4.5
    end

    test "availability atom round-trips a handful of variants" do
      for {atom, label} <- [
            {:in_stock, "InStock"},
            {:out_of_stock, "OutOfStock"},
            {:pre_order, "PreOrder"},
            {:discontinued, "Discontinued"}
          ] do
        result =
          SEO.JSONLD.Product.build(%{
            name: "X",
            offers: SEO.JSONLD.Offer.build(%{price: "1", availability: atom})
          })

        assert result["offers"]["availability"] == "https://schema.org/#{label}"
      end
    end

    test "accepts gtin codes and variant associations" do
      result =
        SEO.JSONLD.Product.build(%{
          name: "Widget",
          gtin13: "1234567890123",
          sku: "SKU-001",
          mpn: "MPN-42",
          is_variant_of: SEO.JSONLD.ProductGroup.build(%{name: "Widget family"})
        })

      assert result["gtin13"] == "1234567890123"
      assert result["sku"] == "SKU-001"
      assert result["mpn"] == "MPN-42"
      assert %{"@type" => "ProductGroup"} = result["isVariantOf"]
    end
  end

  describe "ProfilePage" do
    test "nests main_entity as a Person profile" do
      result =
        SEO.JSONLD.ProfilePage.build(%{
          main_entity: SEO.JSONLD.Person.build(%{name: "Jane", description: "Elixir engineer"}),
          date_created: ~U[2024-01-01 00:00:00Z]
        })

      assert_jsonld(result, "ProfilePage")
      assert %{"@type" => "Person", "name" => "Jane"} = result["mainEntity"]
      assert result["dateCreated"] == "2024-01-01T00:00:00Z"
    end
  end

  describe "QAPage" do
    test "nests a Question with suggested and accepted answers" do
      result =
        SEO.JSONLD.QAPage.build(%{
          main_entity:
            SEO.JSONLD.Question.build(%{
              name: "How do I start a GenServer?",
              text: "Long description here",
              accepted_answer: SEO.JSONLD.Answer.build(%{text: "Call GenServer.start_link/3"}),
              suggested_answer: [
                SEO.JSONLD.Answer.build(%{text: "Use Agent for simpler state"})
              ]
            })
        })

      assert_jsonld(result, "QAPage")
      q = result["mainEntity"]
      assert q["acceptedAnswer"]["text"] == "Call GenServer.start_link/3"
      assert [%{"text" => "Use Agent for simpler state"}] = q["suggestedAnswer"]
    end
  end

  describe "Quiz" do
    test "accepts has_part for individual questions" do
      result =
        SEO.JSONLD.Quiz.build(%{
          name: "Algebra Quiz",
          educational_level: "high school",
          about: SEO.JSONLD.Thing.build(%{name: "Algebra"}),
          has_part: [
            SEO.JSONLD.Question.build(%{
              name: "Solve for x: 2x + 3 = 7",
              accepted_answer: SEO.JSONLD.Answer.build(%{text: "x = 2"})
            })
          ]
        })

      assert_jsonld(result, "Quiz")
      assert result["educationalLevel"] == "high school"
      assert [%{"@type" => "Question"}] = result["hasPart"]
    end
  end

  describe "Recipe" do
    test "example converts durations to ISO 8601 and nests HowToStep list" do
      result = eval_example("recipe.exs")

      assert_jsonld(result, "Recipe")
      assert result["prepTime"] == "PT15M"
      assert result["cookTime"] == "PT12M"
      assert length(result["recipeInstructions"]) == 3
      assert hd(result["recipeInstructions"])["@type"] == "HowToStep"
      assert result["nutrition"]["@type"] == "NutritionInformation"
    end

    test "accepts total_time Duration and video attachment" do
      result =
        SEO.JSONLD.Recipe.build(%{
          name: "Quick Pasta",
          image: "https://example.com/pasta.jpg",
          total_time: Duration.new!(minute: 20),
          video:
            SEO.JSONLD.VideoObject.build(%{
              name: "Cooking pasta",
              thumbnail_url: "https://example.com/v.jpg",
              upload_date: ~D[2024-01-01]
            })
        })

      assert result["totalTime"] == "PT20M"
      assert result["video"]["@type"] == "VideoObject"
    end
  end

  describe "Review" do
    test "example includes author, reviewed item, rating, and date" do
      result = eval_example("review.exs")

      assert_jsonld(result, "Review")
      assert result["datePublished"] == "2024-02-12"
      assert result["itemReviewed"]["@type"] == "Product"
      assert result["reviewRating"]["ratingValue"] == 5
      assert result["reviewRating"]["bestRating"] == 5
    end

    test "accepts worst_rating and publisher" do
      result =
        SEO.JSONLD.Review.build(%{
          item_reviewed: SEO.JSONLD.Product.build(%{name: "Thing"}),
          review_rating:
            SEO.JSONLD.Rating.build(%{rating_value: 3, best_rating: 5, worst_rating: 1}),
          author: SEO.JSONLD.Person.build(%{name: "Critic"}),
          publisher: SEO.JSONLD.Organization.build(%{name: "Review Co"})
        })

      assert result["reviewRating"]["worstRating"] == 1
      assert %{"@type" => "Organization", "name" => "Review Co"} = result["publisher"]
    end
  end

  describe "SoftwareApplication" do
    test "example renders os/category/offers/rating" do
      result = eval_example("software_application.exs")

      assert_jsonld(result, "SoftwareApplication")
      assert result["operatingSystem"] == "macOS, Linux, Windows"
      assert result["applicationCategory"] == "DeveloperApplication"
      assert result["offers"]["price"] == "0"
      assert result["aggregateRating"]["ratingValue"] == 4.8
    end

    test "accepts version, size, and download url" do
      result =
        SEO.JSONLD.SoftwareApplication.build(%{
          name: "App",
          operating_system: "iOS 16+",
          application_category: "GameApplication",
          software_version: "1.2.0",
          file_size: "50 MB",
          download_url: URI.parse("https://example.com/download"),
          software_requirements: "iOS 16.0 or later"
        })

      assert result["softwareVersion"] == "1.2.0"
      assert result["downloadUrl"] == "https://example.com/download"
      assert result["softwareRequirements"] == "iOS 16.0 or later"
    end
  end

  describe "SpeakableSpecification" do
    test "accepts xpath or css selector" do
      result =
        SEO.JSONLD.SpeakableSpecification.build(%{
          xpath: ["/html/body/main/article/h1", "/html/body/main/article/p[1]"],
          css_selector: [".summary", ".headline"]
        })

      assert_jsonld(result, "SpeakableSpecification")
      assert result["xpath"] == ["/html/body/main/article/h1", "/html/body/main/article/p[1]"]
      assert result["cssSelector"] == [".summary", ".headline"]
    end
  end

  describe "VacationRental" do
    test "renders as a LodgingBusiness variant with typical amenities" do
      result =
        SEO.JSONLD.VacationRental.build(%{
          name: "Seaside Cottage",
          image: "https://example.com/cottage.jpg",
          address:
            SEO.JSONLD.PostalAddress.build(%{
              street_address: "1 Coast Rd",
              address_locality: "Cape Cod",
              address_region: "MA",
              postal_code: "02532"
            }),
          aggregate_rating:
            SEO.JSONLD.AggregateRating.build(%{rating_value: 4.7, review_count: 89}),
          amenity_feature: [
            SEO.JSONLD.LocationFeatureSpecification.build(%{
              name: "WiFi",
              value: true
            })
          ]
        })

      assert_jsonld(result, "VacationRental")
      assert result["aggregateRating"]["ratingValue"] == 4.7

      assert [%{"@type" => "LocationFeatureSpecification", "value" => true}] =
               result["amenityFeature"]
    end
  end

  describe "VideoObject" do
    test "example converts upload_date and duration" do
      result = eval_example("video_object.exs")

      assert_jsonld(result, "VideoObject")
      assert result["uploadDate"] == "2024-02-10"
      assert result["duration"] == "PT5M"
      assert result["thumbnailUrl"] == "https://example.com/thumb.jpg"
      assert result["contentUrl"] == "https://example.com/videos/intro.mp4"
    end

    test "accepts thumbnail as ImageObject and interaction stats" do
      result =
        SEO.JSONLD.VideoObject.build(%{
          name: "Deep dive",
          thumbnail_url: "https://example.com/t.jpg",
          upload_date: ~U[2024-02-10 12:00:00Z],
          thumbnail:
            SEO.JSONLD.ImageObject.build(%{
              content_url: "https://example.com/thumb-hq.jpg",
              width: 1280,
              height: 720
            }),
          interaction_statistic:
            SEO.JSONLD.InteractionCounter.build(%{
              interaction_type: SEO.JSONLD.WatchAction.build(%{}),
              user_interaction_count: 50_432
            })
        })

      assert result["uploadDate"] == "2024-02-10T12:00:00Z"
      assert result["thumbnail"]["@type"] == "ImageObject"
      assert result["interactionStatistic"]["@type"] == "InteractionCounter"
      assert result["interactionStatistic"]["userInteractionCount"] == 50_432
    end
  end

  describe "FAQ (hand-crafted convenience)" do
    test "builds an FAQPage from compact question/answer tuples" do
      result =
        SEO.JSONLD.FAQ.build([
          %{question: "Q1?", answer: "A1"},
          %{question: "Q2?", answer: "A2"}
        ])

      assert result["@type"] == "FAQPage"
      assert [q1, _] = result["mainEntity"]
      assert q1["name"] == "Q1?"
      assert q1["acceptedAnswer"]["text"] == "A1"
    end
  end

  describe "Breadcrumbs (hand-crafted convenience)" do
    test "builds a BreadcrumbList with auto-incremented positions" do
      result =
        SEO.JSONLD.Breadcrumbs.build([
          %{name: "Home", item: "https://example.com/"},
          %{name: "Blog", item: "https://example.com/blog/"},
          %{name: "My Post", item: "https://example.com/blog/post-1"}
        ])

      assert_jsonld(result, "BreadcrumbList")
      assert [first, second, third] = result["itemListElement"]
      assert first["@type"] == "ListItem"
      assert first["position"] == 1
      assert first["name"] == "Home"
      assert first["item"] == "https://example.com/"
      assert second["position"] == 2
      assert third["position"] == 3
      assert third["name"] == "My Post"
    end

    test "accepts keyword lists as entries" do
      result =
        SEO.JSONLD.Breadcrumbs.build([
          [name: "Home", item: "https://example.com/"],
          [name: "Blog", item: "https://example.com/blog/"]
        ])

      assert [first, _] = result["itemListElement"]
      assert first["name"] == "Home"
      assert first["position"] == 1
    end

    test "accepts URI structs for item" do
      result =
        SEO.JSONLD.Breadcrumbs.build([
          %{name: "Home", item: URI.parse("https://example.com/")}
        ])

      assert [%{"item" => "https://example.com/"}] = result["itemListElement"]
    end
  end
end
