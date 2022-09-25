defmodule SEOTest do
  use ExUnit.Case
  doctest SEO

  test "greets the world" do
    assert SEO.hello() == :world
  end
end
