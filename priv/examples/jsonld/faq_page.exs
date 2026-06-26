SEO.JSONLD.FAQPage.build(%{
  main_entity: [
    SEO.JSONLD.Question.build(%{
      name: "What is Elixir?",
      accepted_answer:
        SEO.JSONLD.Answer.build(%{
          text: "A functional programming language."
        })
    }),
    SEO.JSONLD.Question.build(%{
      name: "What is Phoenix?",
      accepted_answer:
        SEO.JSONLD.Answer.build(%{
          text: "A web framework for Elixir."
        })
    })
  ]
})
