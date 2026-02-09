defmodule SEO.JsonLD.FAQ do
  @moduledoc """
  Helper for building a Schema.org [FAQPage](https://schema.org/FAQPage) JSON-LD structure.

  Takes a list of question/answer pairs and wraps them in the correct Schema.org format.

  ## Example

      SEO.JsonLD.FAQ.build([
        %{question: "What is Elixir?", answer: "A functional programming language."},
        %{question: "What is Phoenix?", answer: "A web framework for Elixir."}
      ])
  """

  @doc """
  Build a FAQPage JSON-LD map from a list of question/answer pairs.

  Each item in the list should be a map or keyword list with `:question` and `:answer` keys.
  """
  @spec build(list(map() | Keyword.t())) :: map()
  def build(qa_pairs) when is_list(qa_pairs) do
    %{
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => Enum.map(qa_pairs, &build_question/1)
    }
  end

  defp build_question(qa) do
    qa = Enum.into(qa, %{})

    %{
      "@type" => "Question",
      "name" => qa[:question],
      "acceptedAnswer" => %{
        "@type" => "Answer",
        "text" => qa[:answer]
      }
    }
  end
end
