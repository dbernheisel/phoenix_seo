SEO.JSONLD.Review.build(%{
  item_reviewed:
    SEO.JSONLD.Product.build(%{
      name: "Widget",
      image: "https://example.com/widget.jpg",
      offers:
        SEO.JSONLD.Offer.build(%{
          price: "19.99",
          price_currency: "USD",
          availability: :in_stock
        })
    }),
  review_rating:
    SEO.JSONLD.Rating.build(%{
      rating_value: 5,
      best_rating: 5
    }),
  author: SEO.JSONLD.Person.build(%{name: "Jane Doe"}),
  date_published: ~D[2024-02-12],
  review_body: "Excellent widget — does exactly what it promises."
})
