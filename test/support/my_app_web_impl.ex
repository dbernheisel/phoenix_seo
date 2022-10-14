defimpl SEO.OpenGraph.Build, for: MyApp.Article do
  def build(article) do
    SEO.OpenGraph.build(
      type: :article,
      type_detail:
        SEO.OpenGraph.Article.build(
          published_time: ~D[2022-10-13],
          author: article.author,
          section: "Tech"
        ),
      image: image(article),
      title: article.title,
      description: article.description
    )
  end

  defp image(article) do
    file = "/images/article/#{article.id}.png"

    exists? =
      [Application.app_dir(:seo), "/priv/static", file]
      |> Path.join()
      |> File.exists?()

    if exists? do
      SEO.OpenGraph.Image.build(url: file, secure_url: file, alt: article.title)
    end
  end
end

defimpl SEO.OpenGraph.Build, for: MyApp.Book do
  def build(book) do
    SEO.OpenGraph.build(
      type: :book,
      type_detail:
        SEO.OpenGraph.Book.build(
          release_date: book.release_date,
          isbn: book.isbn,
          tag: ["children", "comedy"],
          author: book.author
        ),
      title: book.title,
      description: book.description
    )
  end
end

defimpl SEO.OpenGraph.Build, for: MyApp.Profile do
  def build(profile) do
    SEO.OpenGraph.build(
      type: :profile,
      type_detail:
        SEO.OpenGraph.Profile.build(
          first_name: profile.first_name,
          last_name: profile.last_name,
          gender: profile.gender
        ),
      title: Enum.join([profile.first_name, profile.last_name], " ")
    )
  end
end

defimpl SEO.Site.Build, for: MyApp.Article do
  def build(article) do
    SEO.Site.build(
      url: "https://example.com/#{article.id}",
      title: article.title,
      description: article.description
    )
  end
end

defimpl SEO.Facebook.Build, for: MyApp.Article do
  def build(_article) do
    SEO.Facebook.build(app_id: "123")
  end
end

defimpl SEO.Twitter.Build, for: MyApp.Article do
  def build(article) do
    SEO.Twitter.build(description: article.description, title: article.title)
  end
end

defimpl SEO.Unfurl.Build, for: MyApp.Article do
  def build(article) do
    SEO.Unfurl.build(
      label1: "Title",
      data1: article.title,
      label2: "Reading Time",
      data2: article.reading || "5min"
    )
  end
end

defimpl SEO.Breadcrumb.Build, for: MyApp.Article do
  def build(article) do
    SEO.Breadcrumb.List.build([
      %{name: "Articles", item: "https://example.com/articles"},
      %{name: article.title, item: "https://example.com/articles/#{article.id || "my_id"}"}
    ])
  end
end
