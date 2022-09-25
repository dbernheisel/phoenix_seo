defmodule SEO do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)


  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @seo_options opts
      @before_compile SEO.Compiler
    end
  end

  def define_components(config) do
    quote bind_quoted: [config: config] do
      def meta do

      end
    end
  end
end
