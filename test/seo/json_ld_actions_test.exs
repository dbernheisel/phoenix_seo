# credo:disable-for-this-file Credo.Check.Design.AliasUsage
defmodule SEO.JSONLD.ActionsTest do
  use ExUnit.Case, async: true
  doctest SEO.JSONLD.Actions

  alias SEO.JSONLD.Actions

  describe "input_spec/1" do
    test "flags required inputs" do
      assert Actions.input_spec(required: true) == "required"
    end

    test "renders length and value bounds with Schema.org property names" do
      spec =
        Actions.input_spec(
          required: true,
          max_length: 100,
          min_length: 1,
          value_max: 10,
          value_min: 0,
          name: "q"
        )

      assert spec == "required maxlength=100 minlength=1 valueMax=10 valueMin=0 name=q"
    end

    test "omits nil and false-valued options" do
      assert Actions.input_spec(required: false, name: nil, max_length: 50) == "maxlength=50"
    end

    test "renders multipleValues as a bare flag" do
      assert Actions.input_spec(multiple_values: true, name: "tags") ==
               "multipleValues name=tags"
    end

    test "falls back to camelCased key=value for unknown options" do
      assert Actions.input_spec(some_custom_flag: "value") == "someCustomFlag=value"
    end
  end

  describe "inputs/1" do
    test "expands keyword entries into hyphenated -input keys" do
      assert Actions.inputs(query: [required: true, name: "q"]) == %{
               "query-input" => "required name=q"
             }
    end

    test "camelCases snake_case property atoms" do
      assert Actions.inputs(math_expression: [required: true, name: "expr"]) == %{
               "mathExpression-input" => "required name=expr"
             }
    end

    test "handles multiple entries" do
      result =
        Actions.inputs(
          query: [required: true, name: "q"],
          location: [name: "loc"]
        )

      assert result["query-input"] == "required name=q"
      assert result["location-input"] == "name=loc"
    end
  end

  describe "outputs/1" do
    test "expands into hyphenated -output keys" do
      assert Actions.outputs(review_body: [required: true]) == %{
               "reviewBody-output" => "required"
             }
    end
  end

  describe "composition with an Action builder" do
    test "merges into a SearchAction build" do
      action =
        SEO.JSONLD.SearchAction.build(
          Map.merge(
            %{target: "https://example.com/search?q={q}"},
            Actions.inputs(query: [required: true, max_length: 100, name: "q"])
          )
        )

      assert action["@type"] == "SearchAction"
      assert action["target"] == "https://example.com/search?q={q}"
      assert action["query-input"] == "required maxlength=100 name=q"
    end
  end
end
