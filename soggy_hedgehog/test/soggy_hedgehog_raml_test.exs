defmodule SoggyHedgehogRamlTest do
  use ExUnit.Case, async: true
  doctest SoggyHedgehog.Raml


  test "empty text is a failure" do
    raml = ""
    {:error, _} = SoggyHedgehog.Raml.parse raml
  end

  test "basic parsing" do
    raml = """
    #%RAML 1.0
    title: New Control API
    version: v1
    baseUri: http://localhost
    """


    {:ok, data} = SoggyHedgehog.Raml.parse raml
    assert "New Control API" == data.title
    assert "v1" == data.version
    assert "http://localhost" == data.base_uri
  end

  test "parsing types" do
    raml = """
    #%RAML 1.0
    title: New Control API
    version: v1
    baseUri: http://localhost
    types:
      Broadcast:
        type: object
        properties:
          id: number
          title: string
          summary: string
          deleted: number
    """

    {:ok, data} = SoggyHedgehog.Raml.parse raml

    print_keys data
    IO.puts "Here are the keys in Types"
    print_keys data.types
    assert Map.has_key? data.types, :Broadcast
  end


  defp print_keys(map) do
    map |> Map.keys |> Enum.map(&Atom.to_string/1) |> Enum.join(", ") |> IO.puts
  end
end
