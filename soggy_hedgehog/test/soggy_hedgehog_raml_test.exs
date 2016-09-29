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
    title: New Application API
    version: v1
    baseUri: http://localhost
    """


    {:ok, data} = SoggyHedgehog.Raml.parse raml
    assert "New Application API" == data["title:"]
    assert "v1" == data["version:"]
    assert "http://localhost" == data["baseUri:"]
  end

  test "parsing a type" do
    raml = """
    #%RAML 1.0
    title: New Application API
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
    assert Map.has_key? data["types:"], "Broadcast:"

    assert Map.has_key? data["types:"]["Broadcast:"], "type:"
    assert data["types:"]["Broadcast:"]["type:"] == "object"

    assert Map.has_key? data["types:"]["Broadcast:"], "properties:"
    assert map_size(data["types:"]["Broadcast:"]["properties:"]) == 4
    assert data["types:"]["Broadcast:"]["properties:"]["id:"] == "number"
    assert data["types:"]["Broadcast:"]["properties:"]["title:"] == "string"
    assert data["types:"]["Broadcast:"]["properties:"]["summary:"] == "string"
    assert data["types:"]["Broadcast:"]["properties:"]["deleted:"] == "number"
  end

  test "parsing types" do
    raml = """
    #%RAML 1.0
    title: New Application API
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
    assert Map.has_key? data["types:"], "Broadcast:"

    assert Map.has_key? data["types:"]["Broadcast:"], "type:"
    assert data["types:"]["Broadcast:"]["type:"] == "object"

    assert Map.has_key? data["types:"]["Broadcast:"], "properties:"
    assert map_size(data["types:"]["Broadcast:"]["properties:"]) == 4

    assert Map.has_key? data["types:"], "Document:"
    assert data["types:"]["Document:"]["type:"] == "object"
    assert Map.has_key? data["types:"], "Comment:"
    assert data["types:"]["Comment:"]["properties:"]["fixme:"] == "string"
    assert Map.has_key? data["types:"], "Channel:"

  end


  test "parsing an endpoint with type" do
    raml = """
    #%RAML 1.0
    title: New Application API
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
    /broadcasts:
      get:
        queryParameters:
          tag:
            type: string
          page:
            type: integer
          startDate:
            type: datetime
          notRequired:
            type: string[]
        responses:
          200:
            body:
              application/json:
                type: Broadcast[]
      post:
        body:
          application/json:
            type: broadcasts
    """

    {:ok, data} = SoggyHedgehog.Raml.parse raml
    assert Map.has_key? data["types:"], "Broadcast:"

    assert Map.has_key? data["types:"]["Broadcast:"], "type:"
    assert data["types:"]["Broadcast:"]["type:"] == "object"

    assert Map.has_key? data["types:"]["Broadcast:"], "properties:"
    assert map_size(data["types:"]["Broadcast:"]["properties:"]) == 4
    assert data["types:"]["Broadcast:"]["properties:"]["id:"] == "number"
    assert data["types:"]["Broadcast:"]["properties:"]["title:"] == "string"
    assert data["types:"]["Broadcast:"]["properties:"]["summary:"] == "string"
    assert data["types:"]["Broadcast:"]["properties:"]["deleted:"] == "number"

    assert Map.has_key? data, "endpoints:"
    assert Map.has_key? data["endpoints:"], "/broadcasts:"
    assert map_size(data["endpoints:"]["/broadcasts:"]) == 2
    assert data["endpoints:"]["/broadcasts:"]["get:"]["queryParameters:"]["startDate:"]["type:"] == "datetime"
    
  end

  test "consolidate endpoints" do
    testdata = %{
      "bill" => 7, 
      "chips" => "la la", 
      "/pie:" => %{}, 
      "nothing" => nil, 
      "/chips:" => %{
        "dave" => 1,
        "/holly:" => %{},
        "cat" => 2
      }
    }
    result = SoggyHedgehog.Raml.consolidate_endpoints testdata
    assert Map.has_key? result, "bill"
    assert Map.has_key? result, "chips"
    assert Map.has_key? result, "endpoints:"
    assert Map.has_key? result["endpoints:"], "/pie:"
    assert Map.has_key? result["endpoints:"], "/chips:"
    assert !Map.has_key? result, "/pie:"
    assert !Map.has_key? result, "/chips:"
    assert Map.has_key? result["endpoints:"]["/chips:"], "dave"
    assert Map.has_key? result["endpoints:"]["/chips:"], "cat"
    assert !Map.has_key? result["endpoints:"]["/chips:"], "/holly:"
    assert Map.has_key? result["endpoints:"]["/chips:"], "endpoints:"
    assert Map.has_key? result["endpoints:"]["/chips:"]["endpoints:"], "/holly:"
  end

end
