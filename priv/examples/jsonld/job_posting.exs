SEO.JSONLD.JobPosting.build(%{
  title: "Senior Elixir Engineer",
  description: "Build distributed systems in Elixir.",
  date_posted: ~D[2024-03-01],
  valid_through: ~D[2024-06-01],
  employment_type: "FULL_TIME",
  hiring_organization:
    SEO.JSONLD.Organization.build(%{
      name: "Acme",
      same_as: "https://acme.com",
      logo: "https://acme.com/logo.png"
    }),
  job_location:
    SEO.JSONLD.Place.build(%{
      address:
        SEO.JSONLD.PostalAddress.build(%{
          street_address: "1600 Amphitheatre Pkwy",
          address_locality: "Mountain View",
          address_region: "CA",
          postal_code: "94043",
          address_country: "US"
        })
    }),
  base_salary:
    SEO.JSONLD.MonetaryAmount.build(%{
      currency: "USD",
      value:
        SEO.JSONLD.QuantitativeValue.build(%{
          value: 175_000,
          unit_text: "YEAR"
        })
    })
})
