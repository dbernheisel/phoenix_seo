# credo:disable-for-this-file Credo.Check.Design.AliasUsage
defmodule SEO.JSONLDValidatorFixtureTest do
  @moduledoc """
  Builds one realistic JSON-LD payload per Google-recognized Schema.org type,
  hands them to `SEO.juice/1` via a fixture struct + `SEO.JSONLD.Build` impl,
  and writes the rendered `<script type="application/ld+json">` output into a
  minimal HTML page at `tmp/seo_jsonld_validator.html` (git-ignored).

  Going through `SEO.juice` exercises the real `SEO.JSONLD.meta` component
  and `SEO.JSONLD.Build` protocol path, so any regression in the rendering
  pipeline shows up here. The output is intended for pasting into:

    * https://validator.schema.org/
    * https://search.google.com/test/rich-results
  """
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  @output_path "tmp/seo_jsonld_validator.html"

  @tag :validator
  test "renders every Google rich-result type through SEO.juice" do
    labeled = all_items()
    items = Enum.map(labeled, fn {_label, item} -> item end)

    head_html =
      render_component(&SEO.juice/1,
        conn: %Plug.Conn{},
        item: %SEO.Test.ValidatorFixture{items: items},
        json_library: Jason
      )

    # Sanity: the rendered HTML should contain a single <script
    # type="application/ld+json"> tag with every @type represented.
    assert head_html =~ ~s(<script type="application/ld+json">)

    for {label, item} <- labeled, type <- List.wrap(item["@type"]) do
      assert head_html =~ ~s("#{type}"),
             "#{label} (type #{inspect(type)}) not in rendered output"
    end

    page_html = render_component(&page/1, head_html: head_html, labeled: labeled)

    File.mkdir_p!(Path.dirname(@output_path))
    File.write!(@output_path, page_html)

    IO.puts("""

    Wrote #{length(labeled)} JSON-LD payloads to #{@output_path}.
    Paste the file's source into https://validator.schema.org/ (or
    https://search.google.com/test/rich-results) to validate.
    """)
  end

  attr :head_html, :string, required: true
  attr :labeled, :list, required: true

  def page(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <title>SEO JSON-LD Validator Fixture</title>
        {Phoenix.HTML.raw(@head_html)}
      </head>
      <body>
        <main>
          <article>
            <h1 class="headline">SEO JSON-LD Validator Fixture</h1>
            <p class="summary">
              This page renders one JSON-LD payload per Google rich-result type so the
              whole surface can be validated at schema.org and Rich Results Test.
            </p>
            <p>
              Rendered by <code>SEO.juice/1</code> in
              <code>test/seo/jsonld_validator_fixture_test.exs</code>. Paste this
              page's source into
              <a href="https://validator.schema.org/">validator.schema.org</a>
              or
              <a href="https://search.google.com/test/rich-results">Google's Rich Results Test</a>.
            </p>
            <h2>Payloads included</h2>
            <ol>
              <li :for={{label, _item} <- @labeled}>{label}</li>
            </ol>
          </article>
        </main>
      </body>
    </html>
    """
  end

  defp all_items do
    [
      {"Article", eval_example("article.exs")},
      {"BreadcrumbList (via Breadcrumbs convenience)", breadcrumbs()},
      {"Course", course()},
      {"Dataset", dataset()},
      {"DiscussionForumPosting", discussion_forum_posting()},
      {"EmployerAggregateRating", employer_aggregate_rating()},
      {"Event", eval_example("event.exs")},
      {"FAQPage (via FAQ convenience)", faq()},
      {"ImageObject", eval_example("image_object.exs")},
      {"JobPosting", eval_example("job_posting.exs")},
      {"LocalBusiness", eval_example("local_business.exs")},
      {"MathSolver", math_solver()},
      {"Movie", movie()},
      {"Organization", eval_example("organization.exs")},
      {"Product", eval_example("product.exs")},
      {"ProfilePage", profile_page()},
      {"QAPage", qa_page()},
      {"Quiz", quiz()},
      {"Recipe", eval_example("recipe.exs")},
      {"Review", eval_example("review.exs")},
      {"SoftwareApplication", eval_example("software_application.exs")},
      {"SpeakableSpecification", speakable_specification()},
      {"VacationRental", vacation_rental()},
      {"VideoObject", eval_example("video_object.exs")}
    ]
  end

  defp eval_example(filename) do
    {result, _bindings} = Code.eval_file("priv/examples/jsonld/#{filename}")
    result
  end

  defp breadcrumbs do
    SEO.JSONLD.Breadcrumbs.build([
      %{name: "Home", item: "https://example.com/"},
      %{name: "Guides", item: "https://example.com/guides/"},
      %{name: "Getting Started", item: "https://example.com/guides/getting-started"}
    ])
  end

  defp course do
    SEO.JSONLD.Course.build(%{
      name: "Introduction to Elixir",
      description: "Learn the basics of the Elixir programming language and the BEAM runtime.",
      provider:
        SEO.JSONLD.Organization.build(%{
          name: "Example Academy",
          same_as: "https://example.com/academy"
        }),
      has_course_instance: [
        SEO.JSONLD.CourseInstance.build(%{
          course_mode: "Online",
          course_workload: Duration.new!(hour: 20),
          instructor: SEO.JSONLD.Person.build(%{name: "Jose Valim"})
        })
      ]
    })
  end

  defp dataset do
    SEO.JSONLD.Dataset.build(%{
      name: "NYC Taxi Trip Data",
      description:
        "A dataset capturing NYC taxi trip records over the last decade, including pickup/dropoff locations, fares, and passenger counts.",
      url: "https://example.com/datasets/nyc-taxi",
      keywords: ["NYC", "taxi", "trips", "transportation"],
      license: "https://creativecommons.org/licenses/by/4.0/",
      creator:
        SEO.JSONLD.Organization.build(%{
          name: "NYC TLC",
          url: "https://example.com/org/tlc"
        }),
      temporal_coverage: "2014-01-01/2024-12-31",
      distribution: [
        SEO.JSONLD.DataDownload.build(%{
          encoding_format: "text/csv",
          content_url: "https://example.com/datasets/nyc-taxi/taxi-2024.csv"
        })
      ]
    })
  end

  defp discussion_forum_posting do
    SEO.JSONLD.DiscussionForumPosting.build(%{
      headline: "My take on supervision trees",
      text: "I find that designing the supervision tree first makes the rest fall into place.",
      date_published: ~U[2024-03-12 14:30:00Z],
      url: "https://example.com/forum/supervision-trees",
      author: SEO.JSONLD.Person.build(%{name: "Jane Doe"}),
      interaction_statistic:
        SEO.JSONLD.InteractionCounter.build(%{
          interaction_type: SEO.JSONLD.LikeAction.build(%{}),
          user_interaction_count: 42
        }),
      comment: [
        SEO.JSONLD.Comment.build(%{
          text: "Great point — I agree.",
          date_published: ~U[2024-03-12 15:00:00Z],
          author: SEO.JSONLD.Person.build(%{name: "John Doe"})
        })
      ]
    })
  end

  defp employer_aggregate_rating do
    SEO.JSONLD.EmployerAggregateRating.build(%{
      item_reviewed:
        SEO.JSONLD.Organization.build(%{
          name: "Acme Corp",
          same_as: "https://example.com/acme"
        }),
      rating_value: 4.2,
      rating_count: 257,
      best_rating: 5,
      worst_rating: 1
    })
  end

  defp faq do
    SEO.JSONLD.FAQ.build([
      %{
        question: "What is Elixir?",
        answer: "Elixir is a dynamic, functional language for building scalable applications."
      },
      %{
        question: "What does Phoenix add?",
        answer:
          "Phoenix is a web framework for Elixir focused on productivity and real-time features."
      }
    ])
  end

  defp math_solver do
    SEO.JSONLD.MathSolver.build(%{
      name: "Step-by-step algebra solver",
      url: "https://example.com/math/algebra",
      usage_info: "https://example.com/math/editorial-policy",
      in_language: "en",
      about: "Algebra",
      potential_action: [
        SEO.JSONLD.SolveMathAction.build(%{
          target: "https://example.com/math/algebra?q={math_expression_string}",
          edu_question_type: ["Polynomial Equation", "Linear Equation"],
          inputs: [math_expression: [required: true, name: "math_expression_string"]]
        })
      ]
    })
  end

  defp movie do
    SEO.JSONLD.Movie.build(%{
      name: "The Naysayers",
      image: "https://example.com/movies/naysayers/poster.jpg",
      date_created: ~D[2024-05-10],
      director: SEO.JSONLD.Person.build(%{name: "Jose Valim"}),
      actor: [
        SEO.JSONLD.Person.build(%{name: "Alice"}),
        SEO.JSONLD.Person.build(%{name: "Bob"})
      ],
      genre: "Documentary",
      duration: Duration.new!(minute: 118),
      aggregate_rating: SEO.JSONLD.AggregateRating.build(%{rating_value: 4.7, review_count: 512})
    })
  end

  defp profile_page do
    SEO.JSONLD.ProfilePage.build(%{
      date_created: ~U[2020-01-10 00:00:00Z],
      date_modified: ~U[2024-03-01 12:00:00Z],
      main_entity:
        SEO.JSONLD.Person.build(%{
          name: "Jane Doe",
          alternate_name: "jdoe",
          description: "Elixir engineer and functional programming enthusiast.",
          image: "https://example.com/avatars/jane.jpg",
          same_as: ["https://example.com/twitter/jdoe", "https://example.com/github/jdoe"]
        })
    })
  end

  defp qa_page do
    SEO.JSONLD.QAPage.build(%{
      main_entity:
        SEO.JSONLD.Question.build(%{
          name: "How do I start a GenServer?",
          text: "I'm new to OTP and want to understand the basic call.",
          answer_count: 2,
          date_published: ~U[2024-02-01 09:00:00Z],
          author: SEO.JSONLD.Person.build(%{name: "New Elixir Dev"}),
          accepted_answer:
            SEO.JSONLD.Answer.build(%{
              text: "Call `GenServer.start_link/3` passing your module and initial state.",
              date_published: ~U[2024-02-01 10:00:00Z],
              author: SEO.JSONLD.Person.build(%{name: "OTP Veteran"}),
              upvote_count: 17
            }),
          suggested_answer: [
            SEO.JSONLD.Answer.build(%{
              text: "For simpler state, `Agent` is often enough.",
              author: SEO.JSONLD.Person.build(%{name: "Pragmatist"}),
              upvote_count: 4
            })
          ]
        })
    })
  end

  defp quiz do
    SEO.JSONLD.Quiz.build(%{
      name: "Elixir Fundamentals Quiz",
      about: SEO.JSONLD.Thing.build(%{name: "Elixir"}),
      educational_alignment: [
        SEO.JSONLD.AlignmentObject.build(%{
          alignment_type: "educationalSubject",
          target_name: "Programming"
        })
      ],
      has_part: [
        SEO.JSONLD.Question.build(%{
          name: "Which primitive does Elixir use for IPC?",
          accepted_answer:
            SEO.JSONLD.Answer.build(%{
              text: "Message passing between processes."
            })
        })
      ]
    })
  end

  defp speakable_specification do
    SEO.JSONLD.SpeakableSpecification.build(%{
      xpath: [
        "/html/head/title",
        "/html/body/main/article/h1",
        "/html/body/main/article/p[1]"
      ],
      css_selector: [".summary", ".headline"]
    })
  end

  defp vacation_rental do
    SEO.JSONLD.VacationRental.build(%{
      name: "Seaside Cottage",
      identifier: "seaside-cottage",
      image: [
        "https://example.com/cottage/front.jpg",
        "https://example.com/cottage/living.jpg"
      ],
      address:
        SEO.JSONLD.PostalAddress.build(%{
          street_address: "1 Coast Rd",
          address_locality: "Cape Cod",
          address_region: "MA",
          postal_code: "02532",
          address_country: "US"
        }),
      geo: SEO.JSONLD.GeoCoordinates.build(%{latitude: 41.6869, longitude: -70.6128}),
      aggregate_rating: SEO.JSONLD.AggregateRating.build(%{rating_value: 4.7, review_count: 89}),
      contains_place:
        SEO.JSONLD.Accommodation.build(%{
          name: "Seaside Cottage",
          number_of_bedrooms: 2,
          number_of_bathrooms_total: 1,
          occupancy: SEO.JSONLD.QuantitativeValue.build(%{value: 4}),
          amenity_feature: [
            SEO.JSONLD.LocationFeatureSpecification.build(%{name: "WiFi", value: true}),
            SEO.JSONLD.LocationFeatureSpecification.build(%{name: "Ocean view", value: true})
          ]
        })
    })
  end
end
