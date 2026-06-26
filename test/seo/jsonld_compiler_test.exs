defmodule SEO.JSONLDCompilerTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Compile.SeoJsonld.Generator

  describe "expand_types/1 closure" do
    test ":google pulls in every Google rich-result type" do
      iris = Generator.expand_types([:google])

      for type <- ~w[Article BreadcrumbList Event FAQPage Recipe VideoObject] do
        assert ("schema:" <> type) in iris, "expected schema:#{type} in :google closure"
      end
    end

    test ":google also pulls in referenced types via the field-range closure" do
      # Article.author has range Person|Organization, so both must come
      # along when only `:google` is requested.
      iris = Generator.expand_types([:google])
      assert "schema:Person" in iris
      assert "schema:Organization" in iris
      # ListItem is referenced from BreadcrumbList; needed for the wrapper.
      assert "schema:ListItem" in iris
    end

    test ":google does NOT pull in unrelated types" do
      iris = Generator.expand_types([:google])
      refute "schema:VeterinaryCare" in iris
      refute "schema:GolfCourse" in iris
    end

    test "module names resolve" do
      iris = Generator.expand_types([SEO.JSONLD.Article])
      assert "schema:Article" in iris
    end

    test "schema IRI strings resolve" do
      iris = Generator.expand_types(["schema:Article"])
      assert "schema:Article" in iris
    end

    test "unknown atoms raise with a helpful message" do
      assert_raise ArgumentError, ~r/unknown JSON-LD config entry/, fn ->
        Generator.expand_types([:does_not_exist])
      end
    end

    test ":all returns every regular schema class" do
      iris = Generator.expand_types([:all])
      # Sanity bound: full vocabulary is ~820 classes.
      assert length(iris) > 800
    end

    test "category groups resolve" do
      iris = Generator.expand_types([:place])
      assert "schema:Restaurant" in iris
    end
  end

  describe "emit_sources/1 wrapper handling" do
    test ":google emits Breadcrumbs and FAQ wrappers (deps satisfied)" do
      iris = Generator.expand_types([:google])
      modules = iris |> Generator.emit_sources() |> Enum.map(fn {mod, _, _} -> mod end)

      assert SEO.JSONLD.Breadcrumbs in modules
      assert SEO.JSONLD.FAQ in modules
    end

    test ":google emits Actions wrapper (MathSolver pulls SolveMathAction)" do
      # :google includes MathSolver, which references SolveMathAction (an
      # Action descendant). The Actions wrapper's predicate is "any Action
      # descendant in the closure", so it emits here.
      iris = Generator.expand_types([:google])
      modules = iris |> Generator.emit_sources() |> Enum.map(fn {mod, _, _} -> mod end)

      assert SEO.JSONLD.Actions in modules
    end

    test "Actions wrapper does NOT emit when no Action descendant is in the closure" do
      # SpeakableSpecification is a leaf Intangible — its closure stays in
      # Intangible-land and never reaches an Action descendant.
      iris = Generator.expand_types([SEO.JSONLD.SpeakableSpecification])
      modules = iris |> Generator.emit_sources() |> Enum.map(fn {mod, _, _} -> mod end)

      refute SEO.JSONLD.Actions in modules
    end

    test "Breadcrumbs / FAQ wrappers don't emit when their deps aren't in the closure" do
      # Exercise the predicate directly: pass only a few IRIs to
      # `emit_sources/1` (bypassing the typespec-driven closure walk) and
      # confirm wrappers are excluded when their `when_modules` aren't met.
      sources = Generator.emit_sources(["schema:Person"])
      modules = Enum.map(sources, fn {mod, _, _} -> mod end)

      refute SEO.JSONLD.Breadcrumbs in modules
      refute SEO.JSONLD.FAQ in modules
      assert SEO.JSONLD.Person in modules
    end
  end
end
