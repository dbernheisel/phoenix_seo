defmodule SEO.OpenGraph.Book do
  @moduledoc """
  Metadata describing a book

  ### Resources

  - https://ogp.me/#type_book
  """

  use Phoenix.Component
  alias SEO.Utils

  defstruct [
    :author,
    :isbn,
    :release_date,
    :tag,
    namespace: "https://ogp.me/ns/book#"
  ]

  @type t :: %__MODULE__{
          namespace: String.t(),
          author: SEO.OpenGraph.Profile.t() | list(SEO.OpenGraph.Profile.t()) | String.t(),
          isbn: String.t(),
          release_date: DateTime.t() | NaiveDateTime.t() | Date.t(),
          tag: String.t() | list(String.t())
        }

  @doc """
  Metadata that describes a book.

  - `:author` - Who wrote this book. This may be a `SEO.OpenGraph.Profile` or a list of the profiles.
  - `:isbn` - The ISBN
  - `:release_date` - The date the book was released.
  - `:tag` - Tag words associated with this book.
  """
  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end

  attr(:content, __MODULE__, required: true)

  def meta(assigns) do
    ~H"""
    <meta property="book:release_date" content={Utils.to_iso8601(@content.release_date)} :if={@content.release_date} />
    <meta property="book:isbn" content={@content.isbn} :if={@content.isbn} />
    <meta :for={author <- List.wrap(@content.author)} property="book:author" content={author} :if={List.wrap(@content.author) != []} />
    <meta :for={tag <- List.wrap(@content.tag)} property="book:tag" content={tag} :if={List.wrap(@content.tag) != []} />
    """
  end
end
