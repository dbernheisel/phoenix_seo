defmodule SEOTest do
  use ExUnit.Case
  doctest SEO

  describe "item" do
    test "gets the item from a Plug.Conn" do
      item = %{foo: :bar}
      conn = %Plug.Conn{} |> SEO.assign(item)

      assert ^item = SEO.get(conn)
    end

    test "gets the item from a LiveView Socket" do
      item = %{foo: :bar}
      socket = %Phoenix.LiveView.Socket{} |> SEO.assign(item)

      assert ^item = SEO.get(socket)
    end

    test "gets the item from assigns" do
      item = %{foo: :bar}
      conn = %Plug.Conn{} |> SEO.assign(item)
      socket = %Phoenix.LiveView.Socket{} |> SEO.assign(item)

      assert ^item = SEO.get(conn.assigns)
      assert ^item = SEO.get(socket.assigns)
    end

  end

  describe "assign" do

  end
end
