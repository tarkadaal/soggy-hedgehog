defmodule SoggyHedgehogHtmlOutputTest do
	@template_path "template.eex"
	use ExUnit.Case, async: true

	test "empty input, empty output" do
		nil = SoggyHedgehog.HtmlOutput.render nil
	end

	test "title gets rendered" do
		data = %{"title:" => "Amazing title"}
		output = SoggyHedgehog.HtmlOutput.render data
		result = Floki.find(output, "title") |> Floki.text |> String.trim
		assert result == "Amazing title"
		result = Floki.find(output, "h1") |> Floki.text |> String.trim
		assert result == "Amazing title"
	end

	test "version and URI get rendered" do
		data = %{"version:" => "2.0", "baseUri:" => "http://www.ce.com"}
		output = SoggyHedgehog.HtmlOutput.render data
		result = output |> Floki.find("h5") |> Floki.text |> String.trim |> String.split |> Enum.at(1)
		assert result == "http://www.ce.com"
	end

end