SEO.JSONLD.Event.build(%{
  name: "ElixirConf 2024",
  start_date: ~D[2024-08-28],
  end_date: ~D[2024-08-30],
  event_status: :event_scheduled,
  event_attendance_mode: :offline_event_attendance_mode,
  location:
    SEO.JSONLD.Place.build(%{
      name: "Gaylord Rockies",
      address:
        SEO.JSONLD.PostalAddress.build(%{
          street_address: "6700 N Gaylord Rockies Blvd",
          address_locality: "Aurora",
          address_region: "CO",
          postal_code: "80019"
        })
    }),
  organizer: SEO.JSONLD.Organization.build(%{name: "DockYard"}),
  offers:
    SEO.JSONLD.Offer.build(%{
      price: "599",
      price_currency: "USD",
      availability: :in_stock
    })
})
