defmodule SEO.OpenGraph.Book do
  @moduledoc """

  https://ogp.me/#type_book

  - book - Namespace URI: https://ogp.me/ns/book#
  - book:author - profile array - Who wrote this book.
  - book:isbn - string - The ISBN
  - book:release_date - datetime - The date the book was released.
  - book:tag - string array - Tag words associated with this book.
  """
  defstruct [
    :author,
    :isbn,
    :release_date,
    :tag,
    namespace: "https://ogp.me/ns/book#"
  ]

  @type t :: %__MODULE__{
          namespace: String.t(),
          author: SEO.OpenGraph.Profile.t() | list(SEO.OpenGraph.Profile.t()),
          isbn: String.t(),
          release_date: DateTime.t() | NaiveDateTime.t() | Date.t(),
          tag: String.t() | list(String.t())
        }

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
