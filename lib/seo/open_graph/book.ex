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
          author: URI.t() | String.t() | list(URI.t() | String.t()) | nil,
          isbn: String.t(),
          release_date: DateTime.t() | NaiveDateTime.t() | Date.t(),
          tag: String.t() | list(String.t())
        }

  @doc """
  Metadata that describes a book.

  - `:author` - Who wrote this book. This may be a name or a URL that implements `SEO.OpenGraph.Profile` for the author
    with additional details. This may be supplied as a list of authors.
  - `:isbn` - The ISBN
  - `:release_date` - The date the book was released.
  - `:tag` - Tag words associated with this book.
  """
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    Utils.merge_defaults(__MODULE__, attrs, default)
  end

  attr :content, __MODULE__, default: nil

  def meta(assigns) do
    ~H"""
    <%= if @content do %>
    <%= if @content.isbn do %>
    <meta property="book:isbn" content={@content.isbn} />
    <% end %><%= if @content.release_date do %>
    <meta property="book:release_date" content={Utils.to_iso8601(@content.release_date)} />
    <% end %><%= if (authors = List.wrap(@content.author)) != [] do %>
    <Utils.url :for={author <- authors} property="book:author" content={author} />
    <% end %><%= if (tags = List.wrap(@content.tag)) != [] do %>
    <meta :for={tag <- tags} property="book:tag" content={tag} />
    <% end %>
    <% end %>
    """
  end
end
