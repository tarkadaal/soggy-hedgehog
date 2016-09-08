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

  test "parsing a type" do
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
    assert Map.has_key? data.types, :Broadcast

    assert Map.has_key? data.types[:Broadcast], :type
    assert data.types[:Broadcast].type == "object"

    assert Map.has_key? data.types[:Broadcast], :properties
    assert map_size(data.types[:Broadcast].properties) == 4
    assert data.types[:Broadcast].properties[:id] == "number"
    assert data.types[:Broadcast].properties[:title] == "string"
    assert data.types[:Broadcast].properties[:summary] == "string"
    assert data.types[:Broadcast].properties[:deleted] == "number"
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
      Document:
        type: object
        properties:
          fixme: string
      Comment:
        type: object
        properties:
          fixme: string
      Channel:
        type: object
        properties:
          fixme: string
    """

    {:ok, data} = SoggyHedgehog.Raml.parse raml
    assert Map.has_key? data.types, :Broadcast

    assert Map.has_key? data.types[:Broadcast], :type
    assert data.types[:Broadcast].type == "object"

    assert Map.has_key? data.types[:Broadcast], :properties
    assert map_size(data.types[:Broadcast].properties) == 4

    assert Map.has_key? data.types, :Document
    assert data.types[:Document].type == "object"
    assert Map.has_key? data.types, :Comment
    assert data.types[:Comment].properties[:fixme] == "string"
    assert Map.has_key? data.types, :Channel

  end


  defp print_keys(map) do
    map |> Map.keys |> Enum.map(&Atom.to_string/1) |> Enum.join(", ") |> IO.puts
  end
end
