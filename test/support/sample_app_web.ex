defmodule SampleApp.ArticleController do
  @moduledoc false
  use Phoenix.Controller, formats: [:html, :md]

  plug :put_view, md: SampleApp.ArticleMD

  def show(conn, %{"slug" => slug}) do
    article = SampleApp.Blog.get_article_by_slug!(slug)
    render(conn, :show, article: article)
  end
end

defmodule SampleApp.PageController do
  @moduledoc false
  use Phoenix.Controller, formats: [:html, :md]

  plug :put_view, md: SampleApp.PageMD

  def about(conn, _params) do
    render(conn, :show, page: :about)
  end
end

defmodule SampleApp.Router do
  @moduledoc false
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html", "md"]
  end

  forward "/llms.txt", SEO.LLMs,
    config: MyAppWeb.SEO,
    provider: SampleApp.LLMsProvider

  scope "/", SampleApp do
    pipe_through :browser
    get "/articles/:slug", ArticleController, :show
    get "/about", PageController, :about
  end
end

defmodule SampleApp.Endpoint do
  @moduledoc false
  use Phoenix.Endpoint, otp_app: :phoenix_seo

  plug SampleApp.Router
end
