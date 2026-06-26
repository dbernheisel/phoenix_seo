SEO.JSONLD.Organization.build(%{
  name: "Acme Corp",
  url: "https://acme.com",
  logo: "https://acme.com/logo.png",
  same_as: ["https://twitter.com/acme", "https://github.com/acme"],
  contact_point:
    SEO.JSONLD.ContactPoint.build(%{
      contact_type: "customer service",
      telephone: "+1-555-555-5555",
      email: "support@acme.com"
    })
})
