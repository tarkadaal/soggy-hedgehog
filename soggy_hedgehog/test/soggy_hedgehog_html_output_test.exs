defmodule SoggyHedgehogHtmlOutputTest do
	use ExUnit.Case, async: true

	test "empty input, empty output" do
		nil = SoggyHedgehog.HtmlOutput.render nil
	end

	test "title gets rendered" do
		data = %{"title:" => "Amazing title"}
		output = SoggyHedgehog.HtmlOutput.render data
		result = Floki.find(output, "title") |> Floki.text
		assert result == "Amazing title"
		result = Floki.find(output, "h1") |> Floki.text
		assert result == "Amazing title"
	end

	test "version and URI get rendered" do
		data = %{"version:" => "2.0", "baseUri:" => "http://www.ce.com"}
		output = SoggyHedgehog.HtmlOutput.render data
		IO.puts output
		result = output |> Floki.find("h4") |> Floki.text
		assert result == "http://www.ce.com"
	end

end