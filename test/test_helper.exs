Application.put_env(:phoenix_seo, SampleApp.Endpoint,
  secret_key_base: String.duplicate("a", 64),
  server: false
)

SampleApp.Endpoint.start_link()

ExUnit.start()
