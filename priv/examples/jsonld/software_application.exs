SEO.JSONLD.SoftwareApplication.build(%{
  name: "Acme CLI",
  operating_system: "macOS, Linux, Windows",
  application_category: "DeveloperApplication",
  offers:
    SEO.JSONLD.Offer.build(%{
      price: "0",
      price_currency: "USD"
    }),
  aggregate_rating:
    SEO.JSONLD.AggregateRating.build(%{
      rating_value: 4.8,
      review_count: 312
    })
})
