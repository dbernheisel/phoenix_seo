defmodule SEO.Test.ValidatorFixture do
  @moduledoc """
  Test-support struct used by `SEO.JSONLDValidatorFixtureTest` to feed a
  list of pre-built JSON-LD maps through `SEO.juice/1`. Lives in
  `test/support/` (rather than the test file itself) so the
  `SEO.JSONLD.Build` impl below gets picked up by protocol consolidation.
  """
  defstruct items: []
end

defimpl SEO.JSONLD.Build, for: SEO.Test.ValidatorFixture do
  def build(%{items: items}, _conn), do: items
end
