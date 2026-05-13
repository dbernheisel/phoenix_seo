defmodule Mix.Tasks.Compile.SeoJsonld.Generator do
  @moduledoc false

  # Walks Schema.org's vocabulary (priv/schemaorg.jsonld) and emits typed
  # Elixir builder modules under `SEO.JSONLD.*`. Used by
  # `Mix.Tasks.Compile.SeoJsonld` at consuming-app compile time — not at
  # runtime.
  #
  # The public surface is:
  #
  #   * `groups/0`       - named config groups → schema IRIs
  #   * `expand_types/1` - normalize a config list to the closure of IRIs
  #     to emit (resolves groups, modules, and pulls in referenced types)
  #   * `emit_sources/1` - render `{module_name, source}` pairs for a given
  #     set of IRIs
  #   * `schema_path/0`  - path to the bundled vocabulary file

  # Schema.org's top-level Thing children, used both for the `:medical`,
  # `:place`, etc. config groups AND for ExDoc grouping. Order matters:
  # more specific categories (Action, Medical) come before broader ones
  # (Intangible), so the walk picks the narrowest.
  @category_labels [
    {"schema:Patient", :medical},
    {"schema:MedicalAudience", :medical},
    {"schema:CDCPMDRecord", :medical},
    {"schema:AlignmentObject", :education},
    {"schema:EducationalAudience", :education},
    {"schema:Researcher", :education},
    {"schema:CategoryCode", :education},
    {"schema:StatisticalPopulation", :education},
    {"schema:StatisticalVariable", :education},
    {"schema:ContactPoint", :organization},
    {"schema:EmployeeRole", :organization},
    {"schema:OrganizationRole", :organization},
    {"schema:EntryPoint", :action},
    {"schema:ActionAccessSpecification", :action},
    {"schema:VideoGame", :gaming},
    {"schema:VideoGameSeries", :gaming},
    {"schema:VideoGameClip", :gaming},
    {"schema:Game", :gaming},
    {"schema:GameServer", :gaming},
    {"schema:PlayGameAction", :gaming},
    {"schema:HealthInsurancePlan", :health},
    {"schema:HealthPlanFormulary", :health},
    {"schema:HealthPlanNetwork", :health},
    {"schema:HealthPlanCostSharingSpecification", :health},
    {"schema:Diet", :health},
    {"schema:ExercisePlan", :health},
    {"schema:HealthAndBeautyBusiness", :health},
    {"schema:HealthClub", :health},
    {"schema:NutritionInformation", :health},
    {"schema:EducationalOrganization", :education},
    {"schema:Course", :education},
    {"schema:Quiz", :education},
    {"schema:EducationalOccupationalProgram", :education},
    {"schema:LearningResource", :education},
    {"schema:EducationEvent", :education},
    {"schema:Attorney", :legal},
    {"schema:LegalService", :legal},
    {"schema:Courthouse", :legal},
    {"schema:Notary", :legal},
    {"schema:Permit", :legal},
    {"schema:GovernmentPermit", :legal},
    {"schema:MemberProgram", :legal},
    {"schema:MemberProgramTier", :legal},
    {"schema:ProgramMembership", :legal},
    {"schema:DigitalDocumentPermission", :legal},
    {"schema:GovernmentService", :legal},
    {"schema:RealEstateAgent", :real_estate},
    {"schema:Residence", :real_estate},
    {"schema:Accommodation", :real_estate},
    {"schema:RealEstateListing", :real_estate},
    {"schema:BedDetails", :real_estate},
    {"schema:FloorPlan", :real_estate},
    {"schema:LocationFeatureSpecification", :real_estate},
    {"schema:Trip", :travel},
    {"schema:Reservation", :travel},
    {"schema:LodgingBusiness", :travel},
    {"schema:TravelAgency", :travel},
    {"schema:Airport", :travel},
    {"schema:BusStation", :travel},
    {"schema:TrainStation", :travel},
    {"schema:TaxiStand", :travel},
    {"schema:Taxi", :travel},
    {"schema:TaxiService", :travel},
    {"schema:Seat", :travel},
    {"schema:FinancialService", :financial},
    {"schema:FinancialProduct", :financial},
    {"schema:MonetaryAmount", :financial},
    {"schema:MonetaryAmountDistribution", :financial},
    {"schema:MonetaryGrant", :financial},
    {"schema:Grant", :financial},
    {"schema:DatedMoneySpecification", :financial},
    {"schema:ExchangeRateSpecification", :financial},
    {"schema:FinancialIncentive", :financial},
    {"schema:RepaymentSpecification", :financial},
    {"schema:Product", :shopping},
    {"schema:Brand", :shopping},
    {"schema:MenuItem", :shopping},
    {"schema:OwnershipInfo", :shopping},
    {"schema:TypeAndQuantityNode", :shopping},
    {"schema:ServicePeriod", :shopping},
    {"schema:EngineSpecification", :shopping},
    {"schema:EnergyConsumptionDetails", :shopping},
    {"schema:Offer", :shopping},
    {"schema:OfferCatalog", :shopping},
    {"schema:Demand", :shopping},
    {"schema:Order", :shopping},
    {"schema:OrderItem", :shopping},
    {"schema:Invoice", :shopping},
    {"schema:MerchantReturnPolicy", :shopping},
    {"schema:MerchantReturnPolicySeasonalOverride", :shopping},
    {"schema:Store", :shopping},
    {"schema:PriceSpecification", :shopping},
    {"schema:PaymentMethod", :shopping},
    {"schema:ShippingService", :shopping},
    {"schema:ShippingConditions", :shopping},
    {"schema:ShippingDeliveryTime", :shopping},
    {"schema:ShippingRateSettings", :shopping},
    {"schema:OfferShippingDetails", :shopping},
    {"schema:ParcelDelivery", :shopping},
    {"schema:WarrantyPromise", :shopping},
    {"schema:Ticket", :shopping},
    {"schema:BroadcastService", :media},
    {"schema:BroadcastChannel", :media},
    {"schema:BroadcastFrequencySpecification", :media},
    {"schema:CableOrSatelliteService", :media},
    {"schema:MediaReview", :media},
    {"schema:MediaSubscription", :media},
    {"schema:MediaObject", :media},
    {"schema:Schedule", :event},
    {"schema:InstantaneousEvent", :event},
    {"schema:Observation", :medical},
    {"schema:ComputerLanguage", :creative_work},
    {"schema:HowToItem", :creative_work},
    {"schema:ListItem", :creative_work},
    {"schema:ItemList", :creative_work},
    {"schema:DataFeedItem", :creative_work},
    {"schema:InteractionCounter", :creative_work},
    {"schema:Series", :creative_work},
    {"schema:OpeningHoursSpecification", :place},
    {"schema:Occupation", :jobs},
    {"schema:OccupationalExperienceRequirements", :jobs},
    {"schema:GeoCoordinates", :location},
    {"schema:GeoShape", :location},
    {"schema:GeoCircle", :location},
    {"schema:GeospatialGeometry", :location},
    {"schema:PostalAddress", :location},
    {"schema:PostalCodeRangeSpecification", :location},
    {"schema:VirtualLocation", :location},
    {"schema:Action", :action},
    {"schema:CreativeWork", :creative_work},
    {"schema:Event", :event},
    {"schema:MedicalEntity", :medical},
    {"schema:BioChemEntity", :medical},
    {"schema:Taxon", :medical},
    {"schema:Place", :place},
    {"schema:Organization", :organization},
    {"schema:Person", :person},
    {"schema:Intangible", :intangible}
  ]

  # Schema.org types Google has rich-result guides for. Values are field
  # atoms marked `required()` in each module's `@type t`, sourced from
  # https://developers.google.com/search/docs/appearance/structured-data.
  @google_required %{
    "Article" => [:headline, :image, :date_published, :author],
    "BreadcrumbList" => [:item_list_element],
    "Course" => [:name, :description, :provider],
    "Dataset" => [:name, :description],
    "DiscussionForumPosting" => [:author, :text],
    "EmployerAggregateRating" => [:item_reviewed, :rating_value, :rating_count],
    "Event" => [:name, :start_date, :location],
    "FAQPage" => [:main_entity],
    "ImageObject" => [:content_url],
    "JobPosting" => [:title, :description, :hiring_organization, :date_posted],
    "LocalBusiness" => [:name, :address],
    "MathSolver" => [:name, :url, :usage_info],
    "Movie" => [:name],
    "Organization" => [:name],
    "Product" => [:name, :image],
    "ProfilePage" => [:main_entity],
    "QAPage" => [:main_entity],
    "Quiz" => [:name, :has_part],
    "Recipe" => [:name, :image],
    "Review" => [:item_reviewed, :review_rating, :author],
    "SoftwareApplication" => [:name, :operating_system, :application_category],
    "SpeakableSpecification" => [],
    "VacationRental" => [:name, :image, :address, :identifier],
    "VideoObject" => [:name, :thumbnail_url, :upload_date]
  }

  @google_additional_types %{
    "MathSolver" => ["LearningResource"]
  }

  @google_images %{
    "Article" => ["article-example.png"],
    "BreadcrumbList" => ["breadcrumb-example.png"],
    "Course" => ["course-list-example.png"],
    "Dataset" => ["dataset-search-example.png"],
    "DiscussionForumPosting" => ["discussion-forum-example.png"],
    "EmployerAggregateRating" => ["employer-aggregate-rating-example.png"],
    "Event" => ["event-details-example.png", "event-result-example.png"],
    "FAQPage" => ["faqpage-example.png"],
    "ImageObject" => ["image-metadata-example.png", "image-metadata-example-2.png"],
    "JobPosting" => ["jobs-search-example.png"],
    "LocalBusiness" => ["local-business-example.png"],
    "MathSolver" => ["math-solvers-example.png"],
    "Movie" => ["movie-carousel-example.png"],
    "Organization" => ["organization-example.png"],
    "Product" => ["product-snippet-example.png", "product-variants-example.png"],
    "QAPage" => ["qa-example.png"],
    "Quiz" => ["education-qa-example.png"],
    "Recipe" => ["recipe-example.png", "recipe-example-2.png"],
    "Review" => ["review-snippet-example.png"],
    "SoftwareApplication" => ["software-apps-example.png"],
    "VacationRental" => ["vacation-rental-example.png"],
    "VideoObject" => ["video-example.png"]
  }

  @range_primitive_types %{
    "schema:Text" => :text,
    "schema:URL" => :url,
    "schema:PronounceableText" => :text,
    "schema:CssSelectorType" => :text,
    "schema:XPathType" => :text,
    "schema:Number" => :number,
    "schema:Integer" => :integer,
    "schema:Float" => :float,
    "schema:Boolean" => :boolean,
    "schema:Date" => :date,
    "schema:DateTime" => :datetime,
    "schema:Time" => :time,
    "schema:Duration" => :duration,
    "schema:DateDuration" => :duration
  }

  @module_name_overrides %{
    "3DModel" => "ThreeDimensionModel"
  }

  # Hand-written convenience wrappers shipped under priv/wrappers/.
  # Each entry has:
  #
  #   * `:file`              — filename inside priv/wrappers/
  #   * `:when_modules`      — emit only if every listed module is in the closure
  #   * `:when_descendant_of` — emit only if any module in the closure
  #                              descends from this Schema.org class
  #
  # Entries use exactly one of `:when_modules` / `:when_descendant_of`.
  @wrapper_specs %{
    SEO.JSONLD.Breadcrumbs => %{
      file: "breadcrumbs.ex",
      when_modules: [SEO.JSONLD.BreadcrumbList, SEO.JSONLD.ListItem]
    },
    SEO.JSONLD.FAQ => %{
      file: "faq.ex",
      when_modules: [SEO.JSONLD.FAQPage, SEO.JSONLD.Question, SEO.JSONLD.Answer]
    },
    SEO.JSONLD.Actions => %{
      file: "actions.ex",
      when_descendant_of: "schema:Action"
    }
  }

  # Schema.org classes that `:google` implicitly needs to author its
  # rich-result payloads, even though Google doesn't list them as
  # rich-result types themselves.
  @google_implicit_iris ~w[schema:Question schema:Answer schema:ListItem]

  ## Public API ----------------------------------------------------------

  @doc "Path to the bundled Schema.org vocabulary file."
  @spec schema_path() :: String.t()
  def schema_path do
    Path.join(:code.priv_dir(:phoenix_seo), "schemaorg.jsonld")
  end

  @doc "Path to the hand-written wrapper source files."
  @spec wrappers_dir() :: String.t()
  def wrappers_dir do
    Path.join(:code.priv_dir(:phoenix_seo), "wrappers")
  end

  @doc """
  Named groups available for `config :phoenix_seo, json_ld_types: [...]`.

  Returns a map of group name → list of schema IRIs. `:all` and `:google`
  are computed on demand; the rest come from `@category_labels`.
  """
  @spec groups() :: %{atom() => [String.t()]}
  def groups do
    schema = parse_schema()
    regular = regular_classes(schema)

    by_category =
      Enum.reduce(regular, %{}, fn {id, _class}, acc ->
        category = classify_category(id, schema.classes)
        Map.update(acc, category, [id], &[id | &1])
      end)

    google_iris =
      @google_required
      |> Map.keys()
      |> Enum.map(&("schema:" <> &1))
      |> Enum.concat(@google_implicit_iris)
      |> Enum.uniq()

    Map.merge(by_category, %{
      all: Map.keys(regular),
      google: google_iris
    })
  end

  @doc """
  Normalizes a config list (atoms, modules, schema IRIs, bare names) into
  the transitive closure of schema IRIs that need to be emitted.

  Pulls in:
  - inheritance ancestors (so doc links resolve)
  - field-range references (so typespecs resolve)
  """
  @spec expand_types(atom() | module() | String.t() | list()) :: [String.t()]
  def expand_types(config) do
    config = List.wrap(config)
    schema = parse_schema()
    regular = regular_classes(schema)

    # Fast path: `:all` is by definition the full set; skip the closure
    # walk (which would otherwise iterate every property for every class
    # only to confirm nothing's missing).
    if config == [:all] do
      regular |> Map.keys() |> Enum.sort()
    else
      by_module = module_to_iri(regular)
      groups = groups()

      config
      |> Enum.flat_map(&resolve_one(&1, groups, by_module))
      |> Enum.uniq()
      |> MapSet.new()
      |> close(schema, regular)
      |> MapSet.to_list()
      |> Enum.sort()
    end
  end

  @doc """
  Renders module sources for the given schema IRIs.

  Returns a list of `{module_atom, filename, source_string}` tuples.
  Sources are emitted unformatted — they're machine-generated and only
  need to be valid Elixir, not pretty.
  """
  @spec emit_sources([String.t()]) :: [{module(), String.t(), String.t()}]
  def emit_sources(iris) do
    schema = parse_schema()
    regular = regular_classes(schema)
    id_to_module = build_module_name_map(regular)

    classes = Enum.flat_map(iris, fn id -> List.wrap(Map.get(regular, id)) end)

    # Render in parallel — each class is independent and template
    # expansion dominates the runtime for `:all`.
    generated =
      classes
      |> Task.async_stream(
        fn class -> render_class_source(class, schema, regular, id_to_module) end,
        ordered: false,
        timeout: :infinity
      )
      |> Enum.map(fn {:ok, result} -> result end)

    emitted_modules = MapSet.new(generated, fn {mod, _, _} -> mod end)
    generated ++ emit_wrappers(emitted_modules, iris, schema.classes)
  end

  defp render_class_source(class, schema, _regular, id_to_module) do
    fields = resolve_fields(class, schema.classes, schema.properties, id_to_module)
    name = short_id(class["@id"])
    required = Map.get(@google_required, name, [])
    example = load_example(name)
    images = Map.get(@google_images, name, [])
    action? = "schema:Action" in inheritance_chain(class["@id"], schema.classes)

    source =
      render_module(
        class,
        fields,
        id_to_module,
        schema.enum_class_values,
        required,
        example,
        images,
        action?
      )

    module = Module.concat(SEO.JSONLD, module_name(class))
    filename = Macro.underscore(module_name(class)) <> ".ex"
    {module, filename, source}
  end

  # Hand-written wrappers ship only when the predicate they declare in
  # `@wrapper_specs` is satisfied by the emitted closure.
  defp emit_wrappers(emitted_modules, emitted_iris, classes) do
    iri_set = MapSet.new(emitted_iris)

    for {wrapper, spec} <- @wrapper_specs,
        wrapper_satisfied?(spec, emitted_modules, iri_set, classes) do
      source = wrappers_dir() |> Path.join(spec.file) |> File.read!()
      {wrapper, spec.file, source}
    end
  end

  defp wrapper_satisfied?(%{when_modules: mods}, emitted_modules, _iris, _classes) do
    Enum.all?(mods, &MapSet.member?(emitted_modules, &1))
  end

  defp wrapper_satisfied?(%{when_descendant_of: ancestor}, _emitted_modules, iris, classes) do
    Enum.any?(iris, fn iri ->
      iri != ancestor and ancestor in inheritance_chain(iri, classes)
    end)
  end

  ## Schema parsing ------------------------------------------------------

  @doc false
  def parse_schema do
    raw = schema_path() |> File.read!() |> decode_json()
    {classes, properties, enum_values_by_type} = walk_graph(raw["@graph"])
    enum_class_ids = find_enum_class_ids(classes)
    enum_class_values = build_enum_values_map(enum_class_ids, enum_values_by_type, classes)

    %{
      classes: classes,
      properties: properties,
      enum_values_by_type: enum_values_by_type,
      enum_class_ids: enum_class_ids,
      enum_class_values: enum_class_values
    }
  end

  # Jason is reached transitively via phoenix_live_view → phoenix, so any
  # phoenix_seo consumer has it on the build path. We defer the call via
  # `apply/3` so the dispatch isn't resolved at compile time (would warn
  # because :jason is dev/test-only in this library's own mix.exs).
  defp decode_json(contents) do
    unless Code.ensure_loaded?(Jason) do
      Mix.raise(
        "phoenix_seo: Jason is required at compile time to read the bundled " <>
          "Schema.org vocabulary. Add `{:jason, \"~> 1.0\"}` to your deps."
      )
    end

    # credo:disable-for-next-line Credo.Check.Refactor.Apply
    apply(Jason, :decode!, [contents])
  end

  defp walk_graph(graph) do
    Enum.reduce(graph, {%{}, %{}, %{}}, fn entry, {classes, props, enum_values} ->
      types = list_wrap(entry["@type"])

      cond do
        "rdfs:Class" in types ->
          {Map.put(classes, entry["@id"], entry), props, enum_values}

        "rdf:Property" in types ->
          {classes, Map.put(props, entry["@id"], entry), enum_values}

        Enum.any?(types, &String.starts_with?(&1, "schema:")) ->
          {classes, props, record_enum_value(types, entry, enum_values)}

        true ->
          {classes, props, enum_values}
      end
    end)
  end

  defp record_enum_value(types, entry, enum_values) do
    types
    |> Enum.filter(&String.starts_with?(&1, "schema:"))
    |> Enum.reduce(enum_values, fn type, acc ->
      Map.update(acc, type, [entry], &[entry | &1])
    end)
  end

  defp regular_classes(schema) do
    schema.classes
    |> Enum.filter(fn {id, class} ->
      schema_class?(id) and not data_type?(class, schema.classes) and
        not MapSet.member?(schema.enum_class_ids, id)
    end)
    |> Map.new()
  end

  defp module_to_iri(regular) do
    Map.new(regular, fn {id, class} -> {module_for(class), id} end)
  end

  defp module_for(class), do: Module.concat(SEO.JSONLD, module_name(class))

  ## Config resolution ---------------------------------------------------

  # `:all` and `:google` are special; other atoms are treated as category
  # group names (`:medical`, `:place`, ...). Modules are looked up in the
  # module → IRI map; bare strings ("Article") and IRIs ("schema:Article")
  # are normalized in place.
  defp resolve_one(name, groups, by_module) when is_atom(name) do
    cond do
      Map.has_key?(groups, name) ->
        Map.fetch!(groups, name)

      Map.has_key?(by_module, name) ->
        [Map.fetch!(by_module, name)]

      true ->
        raise ArgumentError,
              "unknown JSON-LD config entry #{inspect(name)}. " <>
                "Expected a group (:all, :google, :medical, …), a module " <>
                "like SEO.JSONLD.Article, or a Schema.org IRI string."
    end
  end

  defp resolve_one("schema:" <> _ = iri, _groups, _by_module), do: [iri]
  defp resolve_one(name, _groups, _by_module) when is_binary(name), do: ["schema:" <> name]

  ## Closure -------------------------------------------------------------

  # Iterate to fixpoint: every emitted class pulls in its inheritance
  # ancestors (for doc links) and the classes its field ranges reference
  # (for typespec references).
  defp close(seeds, schema, regular) do
    do_close(seeds, MapSet.new(), schema, regular)
  end

  defp do_close(set, visited, schema, regular) do
    pending =
      set
      |> MapSet.difference(visited)
      |> MapSet.to_list()

    case pending do
      [] ->
        # Restrict to regular classes — enums and datatypes never get
        # emitted as their own modules.
        Enum.filter(set, &Map.has_key?(regular, &1)) |> MapSet.new()

      ids ->
        new_visited = MapSet.union(visited, MapSet.new(ids))

        added =
          ids
          |> Enum.flat_map(&dependencies(&1, schema, regular))
          |> MapSet.new()

        do_close(MapSet.union(set, added), new_visited, schema, regular)
    end
  end

  defp dependencies(id, schema, regular) do
    class = Map.get(regular, id) || Map.get(schema.classes, id)
    if class, do: deps_from_class(class, schema, regular), else: []
  end

  defp deps_from_class(class, schema, regular) do
    ancestors = inheritance_chain(class["@id"], schema.classes)

    field_ranges =
      schema.properties
      |> Enum.flat_map(fn {_prop_id, prop} ->
        domain_ids = prop |> Map.get("schema:domainIncludes") |> list_wrap() |> ids()

        if Enum.any?(domain_ids, &(&1 in ancestors)) do
          prop |> Map.get("schema:rangeIncludes") |> list_wrap() |> ids()
        else
          []
        end
      end)

    (ancestors ++ field_ranges)
    |> Enum.uniq()
    |> Enum.filter(&Map.has_key?(regular, &1))
  end

  ## Rendering -----------------------------------------------------------

  defp render_module(
         class,
         field_groups,
         id_to_module,
         enum_class_values,
         required,
         example,
         images,
         action?
       ) do
    name = short_id(class["@id"])
    module = module_name(class)

    {map_specs, kw_specs, metadata} =
      classify_fields(field_groups, id_to_module, enum_class_values, required)

    type_value =
      case Map.get(@google_additional_types, name) do
        nil -> name
        extras -> [name | extras]
      end

    action_io_step =
      if action?, do: "        |> SEO.Utils.build_expand_action_io()\n", else: ""

    action_io_doc =
      if action? do
        """

        ## Action inputs and outputs

        This type descends from `SEO.JSONLD.Action`, so `build/1` recognizes
        two pseudo-fields that expand into Schema.org's hyphenated
        `<property>-input` / `<property>-output` shorthand (see
        [Schema.org Actions, Part 4](https://schema.org/docs/actions.html)):

        - `:inputs` — a keyword list of `{property, constraints}` entries
        - `:outputs` — likewise, for `<property>-output` annotations

        Constraints are passed to `SEO.JSONLD.Actions.input_spec/1`.
        """
      else
        ""
      end

    moduledoc = render_moduledoc(name, class, id_to_module, example, images) <> action_io_doc

    fields_doc =
      render_fields_doc(field_groups, id_to_module, enum_class_values, metadata, class["@id"])

    """
    # This file is generated by the :seo_jsonld Mix compiler. Do not edit directly.
    defmodule SEO.JSONLD.#{module} do
      @moduledoc \"\"\"
    #{indent(moduledoc, 2)}
      \"\"\"

      @type attrs ::
              %{
    #{indent(Enum.join(map_specs, ",\n"), 10)}
              }
              | [
    #{indent(Enum.join(kw_specs, ",\n"), 10)}
              ]

      @typedoc \"\"\"
      A JSON-LD map ready to be nested or rendered. String-keyed, always
      includes `"@type"` set to `#{inspect(type_value)}`, plus any camelCased
      field keys the caller provided (see `build/1`). `"@context"` is added
      at render time by `SEO.JSONLD.meta/1` on the top-level node only.
      \"\"\"
      @type t :: %{String.t() => term()}

      @enum_fields #{inspect_enum_fields(metadata.enum_fields)}
      @key_map #{inspect_key_map(metadata.key_map)}

      @doc \"\"\"
      Build a #{name} JSON-LD map.

      ## Fields

    #{indent(fields_doc, 2)}
      \"\"\"
      @spec build(attrs()) :: t()
      def build(attrs) do
        attrs
        |> Enum.into(%{})
    #{action_io_step}    |> SEO.Utils.build_convert_enums(@enum_fields)
        |> SEO.Utils.build_coerce_structs()
        |> SEO.Utils.build_camelize_keys(@key_map)
        |> Map.put_new("@type", #{inspect(type_value)})
      end
    end
    """
  end

  ## Class graph helpers -------------------------------------------------

  defp classify_category(class_id, classes) do
    chain = inheritance_chain(class_id, classes)

    Enum.find_value(@category_labels, :other, fn {ancestor_id, category} ->
      if ancestor_id in chain, do: category
    end)
  end

  defp load_example(class_name) do
    path =
      Path.join([
        :code.priv_dir(:phoenix_seo),
        "examples",
        "jsonld",
        Macro.underscore(class_name) <> ".exs"
      ])

    if File.exists?(path) do
      path |> File.read!() |> String.trim_trailing()
    end
  end

  defp find_enum_class_ids(classes) do
    Enum.reduce(classes, MapSet.new(), fn {id, class}, acc ->
      if in_enumeration_chain?(id, class, classes) do
        MapSet.put(acc, id)
      else
        acc
      end
    end)
  end

  defp in_enumeration_chain?("schema:Enumeration", _class, _classes), do: true

  defp in_enumeration_chain?(_id, class, classes) do
    parent_ids = class |> Map.get("rdfs:subClassOf") |> list_wrap() |> ids()
    Enum.any?(parent_ids, &descends_from_enumeration?(&1, classes, MapSet.new()))
  end

  defp descends_from_enumeration?("schema:Enumeration", _classes, _seen), do: true

  defp descends_from_enumeration?(id, classes, seen) do
    cond do
      MapSet.member?(seen, id) ->
        false

      parent = Map.get(classes, id) ->
        seen = MapSet.put(seen, id)
        parent_ids = parent |> Map.get("rdfs:subClassOf") |> list_wrap() |> ids()
        Enum.any?(parent_ids, &descends_from_enumeration?(&1, classes, seen))

      true ->
        false
    end
  end

  defp build_enum_values_map(enum_class_ids, enum_values_by_type, classes) do
    Map.new(enum_class_ids, fn id ->
      instances = collect_enum_instances(id, enum_values_by_type, classes, MapSet.new())

      value_map =
        instances
        |> Enum.uniq_by(& &1["@id"])
        |> Enum.sort_by(&text(&1["rdfs:label"]))
        |> Map.new(fn entry ->
          label = text(entry["rdfs:label"]) || short_id(entry["@id"])
          atom = label_to_atom(label)
          url = schema_url(entry["@id"])
          {atom, {url, text(entry["rdfs:comment"])}}
        end)

      {id, value_map}
    end)
  end

  defp collect_enum_instances(id, enum_values_by_type, classes, seen) do
    if MapSet.member?(seen, id) do
      []
    else
      seen = MapSet.put(seen, id)
      direct = Map.get(enum_values_by_type, id, [])

      child_instances =
        for {child_id, child_class} <- classes,
            parent_ids = child_class |> Map.get("rdfs:subClassOf") |> list_wrap() |> ids(),
            id in parent_ids,
            instance <- collect_enum_instances(child_id, enum_values_by_type, classes, seen),
            do: instance

      direct ++ child_instances
    end
  end

  defp data_type?(class, classes) do
    descends_from_data_type?(class["@id"], class, classes, MapSet.new())
  end

  defp descends_from_data_type?("schema:DataType", _class, _classes, _seen), do: true
  defp descends_from_data_type?(_id, nil, _classes, _seen), do: false

  defp descends_from_data_type?(id, class, classes, seen) do
    cond do
      MapSet.member?(seen, id) ->
        false

      "schema:DataType" in (class |> Map.get("@type") |> list_wrap()) ->
        true

      true ->
        seen = MapSet.put(seen, id)
        parent_ids = class |> Map.get("rdfs:subClassOf") |> list_wrap() |> ids()

        Enum.any?(parent_ids, fn pid ->
          descends_from_data_type?(pid, Map.get(classes, pid), classes, seen)
        end)
    end
  end

  defp schema_class?("schema:" <> _), do: true
  defp schema_class?(_), do: false

  defp build_module_name_map(classes) do
    Map.new(classes, fn {id, class} -> {id, module_name(class)} end)
  end

  defp module_name(class) do
    raw = short_id(class["@id"])
    Map.get(@module_name_overrides, raw, raw)
  end

  defp short_id("schema:" <> name), do: name
  defp short_id(id), do: id

  defp schema_url("schema:" <> name), do: "https://schema.org/" <> name

  defp resolve_fields(class, classes, properties, id_to_module) do
    chain = inheritance_chain(class["@id"], classes)

    grouped =
      Enum.reduce(properties, %{}, fn {prop_id, prop}, acc ->
        domain_ids = prop |> Map.get("schema:domainIncludes") |> list_wrap() |> ids()

        case Enum.find(chain, &(&1 in domain_ids)) do
          nil ->
            acc

          owner ->
            field = %{
              id: prop_id,
              original_name: short_id(prop_id),
              atom_name: property_name_to_atom(prop),
              comment: clean_comment(prop["rdfs:comment"], id_to_module),
              ranges: prop |> Map.get("schema:rangeIncludes") |> list_wrap() |> ids()
            }

            Map.update(acc, owner, [field], &[field | &1])
        end
      end)

    chain
    |> Enum.map(fn id ->
      fields =
        grouped
        |> Map.get(id, [])
        |> Enum.uniq_by(& &1.atom_name)
        |> Enum.sort_by(& &1.atom_name)

      {id, fields}
    end)
    |> Enum.reject(fn {_id, fields} -> fields == [] end)
  end

  defp inheritance_chain(class_id, classes) do
    do_inheritance_chain([class_id], MapSet.new(), [], classes)
  end

  defp do_inheritance_chain([], _seen, result, _classes), do: Enum.reverse(result)

  defp do_inheritance_chain([id | rest], seen, result, classes) do
    if MapSet.member?(seen, id) do
      do_inheritance_chain(rest, seen, result, classes)
    else
      seen = MapSet.put(seen, id)

      parents =
        case Map.get(classes, id) do
          nil -> []
          class -> class |> Map.get("rdfs:subClassOf") |> list_wrap() |> ids()
        end

      do_inheritance_chain(rest ++ parents, seen, [id | result], classes)
    end
  end

  defp property_name_to_atom(prop) do
    (text(prop["rdfs:label"]) || short_id(prop["@id"]))
    |> Macro.underscore()
    |> String.to_atom()
  end

  defp text(nil), do: nil
  defp text(%{"@value" => v}), do: v
  defp text(v) when is_binary(v), do: v
  defp text(list) when is_list(list), do: list |> Enum.map(&text/1) |> Enum.find(&is_binary/1)

  ## Field classification ------------------------------------------------

  defp classify_fields(field_groups, id_to_module, enum_class_values, required) do
    init = %{enum_fields: %{}, key_map: %{}}
    required_set = MapSet.new(required)
    flat_fields = Enum.flat_map(field_groups, fn {_owner, fields} -> fields end)

    {map_specs, kw_specs, metadata} =
      Enum.reduce(flat_fields, {[], [], init}, fn field, {map_acc, kw_acc, meta} ->
        {map_spec, kw_spec, meta} =
          classify_field(field, id_to_module, enum_class_values, meta, required_set)

        {[map_spec | map_acc], [kw_spec | kw_acc], meta}
      end)

    {Enum.reverse(map_specs), Enum.reverse(kw_specs), metadata}
  end

  defp classify_field(field, id_to_module, enum_class_values, meta, required_set) do
    input_type_string = input_type(field.ranges, id_to_module, enum_class_values)

    qualifier =
      if MapSet.member?(required_set, field.atom_name), do: "required", else: "optional"

    map_spec = "#{qualifier}(#{inspect(field.atom_name)}) => #{input_type_string}"
    kw_spec = "#{field.atom_name}: #{input_type_string}"

    meta =
      meta
      |> maybe_add_key_map(field)
      |> classify_ranges(field, enum_class_values)

    {map_spec, kw_spec, meta}
  end

  defp maybe_add_key_map(meta, field) do
    if to_string(field.atom_name) == field.original_name do
      meta
    else
      %{meta | key_map: Map.put(meta.key_map, field.atom_name, field.original_name)}
    end
  end

  defp classify_ranges(meta, field, enum_class_values) do
    Enum.reduce(field.ranges, meta, fn range, acc ->
      merge_enum_values(acc, field, Map.get(enum_class_values, range))
    end)
  end

  defp merge_enum_values(meta, _field, nil), do: meta

  defp merge_enum_values(meta, field, range_values) do
    values = Map.new(range_values, fn {atom, {url, _comment}} -> {atom, url} end)
    current = Map.get(meta.enum_fields, field.atom_name, %{})

    %{meta | enum_fields: Map.put(meta.enum_fields, field.atom_name, Map.merge(current, values))}
  end

  defp input_type(ranges, id_to_module, enum_class_values) do
    ranges
    |> Enum.flat_map(&range_to_input_type(&1, id_to_module, enum_class_values))
    |> Enum.uniq()
    |> Enum.join(" | ")
    |> case do
      "" -> "term()"
      s -> s
    end
  end

  defp range_to_input_type(range, id_to_module, enum_class_values) do
    cond do
      Map.has_key?(enum_class_values, range) ->
        enum_class_values[range]
        |> Map.keys()
        |> Enum.sort()
        |> Enum.map(&inspect/1)

      prim = @range_primitive_types[range] ->
        input_primitive_strings(prim)

      module = id_to_module[range] ->
        ["SEO.JSONLD.#{module}.t()", "map()"]

      true ->
        ["map()"]
    end
  end

  defp input_primitive_strings(:text), do: ["String.t()"]
  defp input_primitive_strings(:url), do: ["URI.t()", "String.t()"]
  defp input_primitive_strings(:number), do: ["number()"]
  defp input_primitive_strings(:integer), do: ["integer()"]
  defp input_primitive_strings(:float), do: ["float()"]
  defp input_primitive_strings(:boolean), do: ["boolean()"]
  defp input_primitive_strings(:date), do: ["Date.t()", "String.t()"]
  defp input_primitive_strings(:datetime), do: ["DateTime.t()", "NaiveDateTime.t()", "String.t()"]
  defp input_primitive_strings(:time), do: ["Time.t()", "String.t()"]
  defp input_primitive_strings(:duration), do: ["Duration.t()", "String.t()"]

  ## Doc rendering -------------------------------------------------------

  defp render_moduledoc(name, class, id_to_module, example, images) do
    comment = clean_comment(class["rdfs:comment"], id_to_module)
    url = "https://schema.org/#{name}"

    images_block =
      case images do
        [] ->
          nil

        files ->
          Enum.map_join(files, "\n", fn file ->
            "![#{name} rich-result example](./assets/#{file})"
          end)
      end

    example_block =
      if is_binary(example), do: "## Example\n\n```elixir\n#{example}\n```"

    sections =
      [
        comment,
        images_block,
        example_block,
        "Helper for building a Schema.org [#{name}](#{url}) JSON-LD structure."
      ]
      |> Enum.reject(&(&1 in [nil, ""]))

    Enum.join(sections, "\n\n")
  end

  defp render_fields_doc(field_groups, id_to_module, enum_class_values, metadata, own_id) do
    {own_group, inherited_groups} =
      case Enum.split_with(field_groups, fn {id, _} -> id == own_id end) do
        {[own], rest} -> {own, rest}
        {[], rest} -> {{own_id, []}, rest}
      end

    own_section = render_own_fields(own_group, id_to_module, enum_class_values, metadata)
    inherited_section = render_inherited_fields(inherited_groups, id_to_module)

    [own_section, inherited_section]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join("\n\n")
  end

  defp render_own_fields({_owner_id, []}, _id_to_module, _enum_class_values, _metadata) do
    "This type has no own properties. See the inherited properties below."
  end

  defp render_own_fields({_owner_id, fields}, _id_to_module, enum_class_values, metadata) do
    Enum.map_join(fields, "\n", fn field ->
      comment = field.comment || ""
      enum_note = enum_value_list(field, enum_class_values, metadata)
      "- `#{inspect(field.atom_name)}` - #{comment}#{enum_note}"
    end)
  end

  defp render_inherited_fields([], _id_to_module), do: nil

  defp render_inherited_fields(groups, id_to_module) do
    links =
      Enum.map_join(groups, "\n", fn {owner_id, _fields} ->
        "- #{owner_link(owner_id, short_id(owner_id), id_to_module)}"
      end)

    """
    ### Inherited properties

    Additional properties are available through the inheritance chain. See
    each ancestor's docs for its properties:

    #{links}\
    """
  end

  defp owner_link(owner_id, owner_name, id_to_module) do
    case Map.get(id_to_module, owner_id) do
      nil -> owner_name
      _module -> "`SEO.JSONLD.#{Map.get(id_to_module, owner_id)}`"
    end
  end

  defp enum_value_list(field, _enum_class_values, metadata) do
    case Map.get(metadata.enum_fields, field.atom_name) do
      nil ->
        ""

      values ->
        atoms = values |> Map.keys() |> Enum.sort() |> Enum.map_join(", ", &"`#{inspect(&1)}`")
        " One of: #{atoms}."
    end
  end

  defp clean_comment(nil, _id_to_module), do: ""

  defp clean_comment(comment, id_to_module) do
    case text(comment) do
      nil ->
        ""

      string ->
        string
        |> String.replace(~r/<[^>]+>/, "")
        |> String.replace("\\n", "\n")
        |> absolutize_schema_links()
        |> linkify_refs(id_to_module)
        |> String.replace(~r/[ \t]+/, " ")
        |> String.replace(~r/ *\n */, "\n")
        |> String.replace(~r/\n{3,}/, "\n\n")
        |> String.trim()
    end
  end

  defp absolutize_schema_links(text) do
    Regex.replace(~r{\]\((/[^)]*)\)}, text, fn _, path ->
      "](https://schema.org#{path})"
    end)
  end

  defp linkify_refs(text, id_to_module) do
    Regex.replace(~r/\[\[([A-Za-z0-9_]+)\]\]/, text, fn _, name ->
      schema_id = "schema:" <> name

      case Map.get(id_to_module, schema_id) do
        nil -> "`#{name}`"
        module -> "`SEO.JSONLD.#{module}`"
      end
    end)
  end

  defp inspect_enum_fields(enum_fields) when map_size(enum_fields) == 0, do: "%{}"

  defp inspect_enum_fields(enum_fields) do
    entries =
      enum_fields
      |> Enum.sort_by(fn {k, _} -> k end)
      |> Enum.map_join(",\n", fn {field, values} ->
        value_entries =
          values
          |> Enum.sort_by(fn {k, _} -> k end)
          |> Enum.map_join(",\n", fn {atom, url} ->
            "  #{inspect(atom)} => #{inspect(url)}"
          end)

        "#{inspect(field)} => %{\n#{value_entries}\n}"
      end)

    "%{\n#{entries}\n}"
  end

  defp inspect_key_map(key_map) when map_size(key_map) == 0, do: "%{}"

  defp inspect_key_map(key_map) do
    entries =
      key_map
      |> Enum.sort_by(fn {k, _} -> k end)
      |> Enum.map_join(",\n", fn {k, v} -> "  #{inspect(k)} => #{inspect(v)}" end)

    "%{\n#{entries}\n}"
  end

  defp list_wrap(nil), do: []
  defp list_wrap(list) when is_list(list), do: list
  defp list_wrap(x), do: [x]

  defp ids(entries), do: Enum.map(entries, & &1["@id"])

  defp label_to_atom(label) when is_binary(label) do
    label |> Macro.underscore() |> String.to_atom()
  end

  defp indent(text, spaces) do
    pad = String.duplicate(" ", spaces)

    text
    |> String.split("\n")
    |> Enum.map_join("\n", fn
      "" -> ""
      line -> pad <> line
    end)
  end
end
