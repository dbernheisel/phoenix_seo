# Generator for SEO.JSONLD.* modules.
#
# Reads priv/schemaorg.jsonld and emits one module per regular Schema.org class
# into lib/seo/json_ld/. Enumeration classes are elided; their values are folded
# into atom-literal unions on the fields that reference them.
#
# Run with: mix run priv/gen_json_ld.exs

defmodule SEO.JSONLD.Generator do
  @moduledoc false

  @schema_path Path.join(["priv", "schemaorg.jsonld"])
  @examples_dir Path.join(["priv", "examples", "jsonld"])
  @output_dir Path.join(["lib", "seo", "json_ld"])
  @mix_exs_path "mix.exs"

  # Schema.org's top-level Thing children. When a class's inheritance chain
  # is walked, the first ancestor that matches one of these keys becomes
  # that class's category — used by mix.exs to split the ~800 non-curated
  # types into navigable ExDoc groups instead of one "JSON-LD" blob.
  # Order matters: more specific categories (Action, Medical) come before
  # broader ones (Intangible), so the walk picks the narrowest.
  @category_labels [
    # Special-case classes that would otherwise land in a less-useful
    # ancestor bucket.
    {"schema:Patient", :medical},

    # Medical (via audience/data lineage, not MedicalEntity).
    {"schema:MedicalAudience", :medical},
    {"schema:CDCPMDRecord", :medical},

    # Education (via audience/alignment lineage + statistics/codes).
    {"schema:AlignmentObject", :education},
    {"schema:EducationalAudience", :education},
    {"schema:Researcher", :education},
    {"schema:CategoryCode", :education},
    {"schema:StatisticalPopulation", :education},
    {"schema:StatisticalVariable", :education},

    # Organization roles and contact.
    {"schema:ContactPoint", :organization},
    {"schema:EmployeeRole", :organization},
    {"schema:OrganizationRole", :organization},

    # Action infrastructure (EntryPoint = Action.target, AccessSpec = ConsumeAction).
    {"schema:EntryPoint", :action},
    {"schema:ActionAccessSpecification", :action},

    # Gaming — video games, game servers, play action.
    {"schema:VideoGame", :gaming},
    {"schema:VideoGameSeries", :gaming},
    {"schema:VideoGameClip", :gaming},
    {"schema:Game", :gaming},
    {"schema:GameServer", :gaming},
    {"schema:PlayGameAction", :gaming},

    # Health — wellness, insurance, plans.
    {"schema:HealthInsurancePlan", :health},
    {"schema:HealthPlanFormulary", :health},
    {"schema:HealthPlanNetwork", :health},
    {"schema:HealthPlanCostSharingSpecification", :health},
    {"schema:Diet", :health},
    {"schema:ExercisePlan", :health},
    {"schema:HealthAndBeautyBusiness", :health},
    {"schema:HealthClub", :health},
    {"schema:NutritionInformation", :health},

    # Education — schools + programs + learning resources.
    {"schema:EducationalOrganization", :education},
    {"schema:Course", :education},
    {"schema:Quiz", :education},
    {"schema:EducationalOccupationalProgram", :education},
    {"schema:LearningResource", :education},
    {"schema:EducationEvent", :education},

    # Legal — attorney/service businesses, permits, memberships, government.
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

    # Real Estate — listings, accommodations, residences, room specs.
    {"schema:RealEstateAgent", :real_estate},
    {"schema:Residence", :real_estate},
    {"schema:Accommodation", :real_estate},
    {"schema:RealEstateListing", :real_estate},
    {"schema:BedDetails", :real_estate},
    {"schema:FloorPlan", :real_estate},
    {"schema:LocationFeatureSpecification", :real_estate},

    # Travel — trips, reservations, transit, and travel-specific businesses.
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

    # Financial — money, banks, accounts, grants.
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

    # Shopping — products, offers, orders, pricing, shipping, returns, brands,
    # vehicle/product specs.
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

    # Media — broadcast, channels, media objects, subscriptions.
    {"schema:BroadcastService", :media},
    {"schema:BroadcastChannel", :media},
    {"schema:BroadcastFrequencySpecification", :media},
    {"schema:CableOrSatelliteService", :media},
    {"schema:MediaReview", :media},
    {"schema:MediaSubscription", :media},
    {"schema:MediaObject", :media},

    # Event — schedules and instantaneous events.
    {"schema:Schedule", :event},
    {"schema:InstantaneousEvent", :event},

    # Medical — disease statistics observations.
    {"schema:Observation", :medical},

    # Creative Work — lists, how-to items, interaction counters.
    {"schema:ComputerLanguage", :creative_work},
    {"schema:HowToItem", :creative_work},
    {"schema:ListItem", :creative_work},
    {"schema:ItemList", :creative_work},
    {"schema:DataFeedItem", :creative_work},
    {"schema:InteractionCounter", :creative_work},
    {"schema:Series", :creative_work},

    # Place — opening hours.
    {"schema:OpeningHoursSpecification", :place},

    # Jobs & Occupations.
    {"schema:Occupation", :jobs},
    {"schema:OccupationalExperienceRequirements", :jobs},

    # Location — abstract geo + address descriptors.
    {"schema:GeoCoordinates", :location},
    {"schema:GeoShape", :location},
    {"schema:GeoCircle", :location},
    {"schema:GeospatialGeometry", :location},
    {"schema:PostalAddress", :location},
    {"schema:PostalCodeRangeSpecification", :location},
    {"schema:VirtualLocation", :location},

    # Top-level Thing branches (broad fallbacks).
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
  # Hand-written convenience wrappers kept alongside the generated Schema.org
  # modules. The generator never touches these, so regeneration is safe.
  @preserved_files ~w[
    actions.ex
    build.ex
    breadcrumbs.ex
    faq.ex
  ]

  # Schema.org class names that are invalid Elixir module names (or otherwise need renaming).
  @module_name_overrides %{
    "3DModel" => "ThreeDimensionModel"
  }

  # Schema.org types Google has rich-result guides for. Keys are used by the
  # ExDoc "JSON-LD" group in mix.exs. Values are field atoms marked
  # `required()` in each module's `@type t`, sourced from
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
    # Google's Product rich result also requires at least one of :offers,
    # :review, or :aggregate_rating — that "or" isn't expressible in Elixir
    # typespecs, so it's documented in the moduledoc rather than enforced
    # via `required()`.
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

  @doc "List of Schema.org class names Google has rich-result guides for."
  def google_types, do: Map.keys(@google_required)

  # Extra `@type` values Google expects alongside the module's own type.
  # A MathSolver rich result, for instance, is only recognized when the
  # payload's `@type` is `["MathSolver", "LearningResource"]` — the module
  # auto-emits this list so users don't have to know which types need
  # cross-declaration for Google's validator.
  @google_additional_types %{
    "MathSolver" => ["LearningResource"]
  }

  # Screenshots from Google's rich-result docs. Files live in assets/ and are
  # copied into the ExDoc output via `mix.exs` `docs: [assets: ...]`. Each
  # listed image appears at the top of the corresponding moduledoc.
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

  # Maps schema:* range types to an internal tag we use for routing in build/1.
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

  def run do
    {classes, properties, enum_values_by_type} = parse_schema()

    enum_class_ids = find_enum_class_ids(classes)
    enum_class_values = build_enum_values_map(enum_class_ids, enum_values_by_type, classes)

    regular_classes =
      classes
      |> Enum.filter(fn {id, class} ->
        schema_class?(id) and not data_type?(class, classes) and
          not MapSet.member?(enum_class_ids, id)
      end)
      |> Map.new()

    id_to_module = build_module_name_map(regular_classes)

    cleanup_output_dir()

    Enum.each(regular_classes, fn {_id, class} ->
      fields = resolve_fields(class, classes, properties, id_to_module)
      name = short_id(class["@id"])
      required = Map.get(@google_required, name, [])
      example = load_example(name)
      images = Map.get(@google_images, name, [])
      action? = "schema:Action" in inheritance_chain(class["@id"], classes)

      source =
        render_module(
          class,
          fields,
          id_to_module,
          enum_class_values,
          required,
          example,
          images,
          action?
        )

      path = Path.join(@output_dir, filename(class))
      File.write!(path, [Code.format_string!(source), ?\n])
    end)

    write_categories(regular_classes, classes)

    IO.puts("Generated #{map_size(regular_classes)} JSON-LD modules into #{@output_dir}")
  end

  # Rewrites the `@json_ld_categories` module attribute inside mix.exs
  # between the `@begin_json_ld_categories` / `@end_json_ld_categories`
  # markers. This keeps the category data inline (no external file for hex
  # consumers to worry about) while still being generator-maintained.
  defp write_categories(regular_classes, classes) do
    categories =
      regular_classes
      |> Enum.map(fn {id, _class} ->
        category = classify_category(id, classes)
        module = Module.concat([SEO.JSONLD, module_name(classes[id])])
        {module, category}
      end)
      |> Enum.sort()

    body =
      Enum.map_join(categories, ",\n", fn {module, category} ->
        "    #{inspect(module)} => #{inspect(category)}"
      end)

    replacement = """
    # @begin_json_ld_categories
      @json_ld_categories %{
    #{body}
      }
      # @end_json_ld_categories\
    """

    mix_exs = File.read!(@mix_exs_path)

    updated =
      Regex.replace(
        ~r/# @begin_json_ld_categories.*# @end_json_ld_categories/s,
        mix_exs,
        replacement
      )

    File.write!(@mix_exs_path, updated)
  end

  defp classify_category(class_id, classes) do
    chain = inheritance_chain(class_id, classes)

    Enum.find_value(@category_labels, :other, fn {ancestor_id, category} ->
      if ancestor_id in chain, do: category
    end)
  end

  # Looks up an example at priv/examples/jsonld/<snake_case>.exs. Returns nil
  # when no file exists, letting the fallback auto-example run.
  defp load_example(class_name) do
    path = Path.join(@examples_dir, Macro.underscore(class_name) <> ".exs")

    if File.exists?(path) do
      path |> File.read!() |> String.trim_trailing()
    end
  end

  defp parse_schema do
    schema = @schema_path |> File.read!() |> Jason.decode!()

    Enum.reduce(schema["@graph"], {%{}, %{}, %{}}, fn entry, {classes, props, enum_values} ->
      types = list_wrap(entry["@type"])

      cond do
        "rdfs:Class" in types ->
          {Map.put(classes, entry["@id"], entry), props, enum_values}

        "rdf:Property" in types ->
          {classes, Map.put(props, entry["@id"], entry), enum_values}

        Enum.any?(types, &String.starts_with?(&1, "schema:")) ->
          # Enumeration value. A value may declare multiple parent enum types.
          enum_types = Enum.filter(types, &String.starts_with?(&1, "schema:"))

          new_enum_values =
            Enum.reduce(enum_types, enum_values, fn type, acc ->
              Map.update(acc, type, [entry], &[entry | &1])
            end)

          {classes, props, new_enum_values}

        true ->
          {classes, props, enum_values}
      end
    end)
  end

  # Classes whose subClassOf chain reaches (or is) schema:Enumeration.
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

  # Find all instances declared for each enumeration class, walking upward so
  # subtypes of an enum class inherit their parent's instances too.
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

      # Also walk subclasses of this enum type so parent types include child values.
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

  defp filename(class) do
    module_name(class) |> Macro.underscore() |> Kernel.<>(".ex")
  end

  defp short_id("schema:" <> name), do: name
  defp short_id(id), do: id

  defp schema_url("schema:" <> name), do: "https://schema.org/" <> name

  # Returns a list of `{owner_class_id, [field]}` tuples ordered by the
  # inheritance chain (most-specific first, `schema:Thing` last). Each
  # property is placed under the most-specific ancestor whose
  # `schema:domainIncludes` declares it, matching how schema.org's own
  # class pages group "Properties of X" sections.
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

  # BFS from the given class up through its ancestry, returning ids in
  # visit order ([self, parent1, parent2, grandparent1, ..., Thing]).
  # Preserves the source order of parents from `rdfs:subClassOf` — for
  # LocalBusiness (parents `Place, Organization`), the chain is
  # [LocalBusiness, Place, Organization, Thing].
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

  # Schema.org sometimes wraps labels/comments as JSON-LD language-tagged
  # literals (`%{"@language" => "en", "@value" => "..."}`). Normalize both
  # plain strings and tagged objects to a bare string.
  defp text(nil), do: nil
  defp text(%{"@value" => v}), do: v
  defp text(v) when is_binary(v), do: v
  defp text(list) when is_list(list), do: list |> Enum.map(&text/1) |> Enum.find(&is_binary/1)

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

    # Action descendants get an extra pipeline step that expands the
    # `:inputs` / `:outputs` pseudo-fields into Schema.org's hyphenated
    # `<property>-input` / `<property>-output` keys.
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
    # This file is generated by priv/gen_json_ld.exs. Do not edit directly.
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
      A JSON-LD map ready to be serialized. String-keyed, always includes
      `"@context"` and `"@type"` set to `"https://schema.org"` and
      `#{inspect(type_value)}` respectively, plus any camelCased field keys
      the caller provided (see `build/1`).
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
        |> Map.put_new("@context", "https://schema.org")
        |> Map.put_new("@type", #{inspect(type_value)})
      end
    end
    """
  end

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

  # Fields accept their range-derived union. JSON-LD does allow most fields
  # to be a list of the same type, but blanket-wrapping every spec with
  # `| [T]` doubled every signature. Users passing a list at runtime still
  # works (Elixir maps are untyped at runtime); dialyzer just won't
  # specifically validate the list form.
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

  # Per-field metadata the generated module needs at runtime: which fields
  # take an enum atom (plus each atom's target URL). Temporal/URI struct
  # coercion is universal (see `SEO.Utils.build_coerce_structs/1`), so no
  # per-field allowlist is baked in for those.
  defp classify_ranges(meta, field, enum_class_values) do
    Enum.reduce(field.ranges, meta, fn range, acc ->
      if Map.has_key?(enum_class_values, range) do
        current = Map.get(acc.enum_fields, field.atom_name, %{})

        values =
          enum_class_values[range]
          |> Map.new(fn {atom, {url, _comment}} -> {atom, url} end)

        %{
          acc
          | enum_fields: Map.put(acc.enum_fields, field.atom_name, Map.merge(current, values))
        }
      else
        acc
      end
    end)
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

  # Renders only the class's own fields; inherited fields are represented
  # as a short list of ancestor module links the reader can click through
  # to. Keeps per-module docs focused (Plumber had 70+ inherited bullets
  # before; now it lists just its own plus four ancestor links).
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

  # Link the owning class to its generated module if we emit one, otherwise
  # leave the name as plain text (e.g. for `Thing`, which is itself generated,
  # but fall back gracefully for anything that isn't).
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

  # Schema.org comments embed markdown links whose hrefs are relative to
  # https://schema.org — e.g. `[background notes](/docs/datamodel.html)`.
  # Rewrite any `](/path)` to an absolute schema.org URL so ExDoc doesn't
  # try to resolve them against our docs site.
  defp absolutize_schema_links(text) do
    Regex.replace(~r{\]\((/[^)]*)\)}, text, fn _, path ->
      "](https://schema.org#{path})"
    end)
  end

  # Rewrites Schema.org's `[[Term]]` references. Capitalized terms that resolve
  # to a generated module become ExDoc module links (`SEO.JSONLD.Term`); all
  # other terms (properties, unknown classes) fall back to code spans.
  defp linkify_refs(text, id_to_module) do
    Regex.replace(~r/\[\[([A-Za-z0-9_]+)\]\]/, text, fn _, name ->
      schema_id = "schema:" <> name

      case Map.get(id_to_module, schema_id) do
        nil -> "`#{name}`"
        module -> "`SEO.JSONLD.#{module}`"
      end
    end)
  end

  # `inspect` on a %{atom => %{atom => binary}} map renders in a single line
  # and looks ugly for large enum tables; render one key per line instead.
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

  defp cleanup_output_dir do
    @output_dir
    |> File.ls!()
    |> Enum.each(fn file ->
      if Path.extname(file) == ".ex" and file not in @preserved_files do
        File.rm!(Path.join(@output_dir, file))
      end
    end)
  end
end

SEO.JSONLD.Generator.run()
