SEO.JSONLD.LocalBusiness.build(%{
  name: "Joe's Pizza",
  telephone: "+1-555-555-5555",
  price_range: "$$",
  address:
    SEO.JSONLD.PostalAddress.build(%{
      street_address: "123 Main St",
      address_locality: "Springfield",
      address_region: "IL",
      postal_code: "62701"
    }),
  geo:
    SEO.JSONLD.GeoCoordinates.build(%{
      latitude: 39.7817,
      longitude: -89.6501
    })
})
