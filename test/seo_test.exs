defmodule SEOTest do
  use ExUnit.Case
  doctest SEO

  describe "item" do
    test "gets the item from a Plug.Conn" do
      item = %{foo: :bar}
      conn = %Plug.Conn{} |> SEO.assign(item)

      assert ^item = SEO.item(conn)
    end

    test "gets the item from a LiveView Socket" do
      item = %{foo: :bar}
      socket = %Phoenix.LiveView.Socket{} |> SEO.assign(item)

      assert ^item = SEO.item(socket)
    end
  end

  describe "assign" do
    test "assigns for a Plug.Conn" do
      item = %{foo: :bar}
      conn = %Plug.Conn{} |> SEO.assign(item)

      assert %{private: %{seo: ^item}} = conn
    end

    test "assigns for a LiveView Socket" do
      item = %{foo: :bar}
      socket = %Phoenix.LiveView.Socket{} |> SEO.assign(item)

      assert %{assigns: %{seo: ^item}} = socket
    end
  end
end
