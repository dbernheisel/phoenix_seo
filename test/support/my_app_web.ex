defmodule MyAppWeb.SEO do
  @moduledoc false

  use SEO,
    json_library: Jason,
    site:
      SEO.Site.build(
        default_title: "Default Title",
        description: "A blog about development",
        title_suffix: "Suf"
      ),
    open_graph:
      SEO.OpenGraph.build(
        description: "A blog about development",
        site_name: "David Bernheisel's Blog",
        type: :website,
        locale: "en_US"
      ),
    twitter:
      SEO.Twitter.build(
        site: "@bernheisel",
        site_id: "27704724",
        creator: "@bernheisel",
        creator_id: "27704724",
        card: :summary
      )
end

defmodule MyApp.Article do
  @moduledoc false
  defstruct [:id, :title, :description, :author, :reading]
end

defmodule MyApp.Book do
  @moduledoc false
  defstruct [:id, :title, :isbn, :description, :author, :release_date]
end

defmodule MyApp.Profile do
  @moduledoc false
  defstruct [:id, :last_name, :first_name, :gender]
end

defmodule MyApp.NotImplemented do
  @moduledoc false
  defstruct [:id]
end
