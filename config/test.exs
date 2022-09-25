import Config

config :phoenix, json_library: Jason

config :seo,
  json_library: Jason

config :seo, SEO.Site,
  default_page_title: "David Bernheisel's Blog",
  description: "A blog about development",
  page_title_prefix: nil,
  page_title_suffix: nil

config :seo, SEO.OpenGraph,
  description: "A blog about development",
  site_name: "David Bernheisel's Blog",
  type: "website",
  locale: "en_US"

config :seo, SEO.Twitter,
  site: "@bernheisel",
  site_id: "27704724",
  creator: "@bernheisel",
  creator_id: "27704724",
  card: :summary
