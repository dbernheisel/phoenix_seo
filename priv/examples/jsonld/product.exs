SEO.JSONLD.Product.build(%{
  name: "Widget",
  description: "A great widget",
  image: "https://example.com/widget.jpg",
  brand: SEO.JSONLD.Brand.build(%{name: "Acme"}),
  offers:
    SEO.JSONLD.Offer.build(%{
      price: "19.99",
      price_currency: "USD",
      availability: :in_stock
    }),
  aggregate_rating:
    SEO.JSONLD.AggregateRating.build(%{
      rating_value: 4.5,
      review_count: 142
    })
})
