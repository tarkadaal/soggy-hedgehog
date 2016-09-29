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

      # responses:
      #   200:
      #     body:
      #       application/json:
      #         type: Broadcast


	test "response santization" do
		data = %{
			"responses:" => %{
				"200:" => %{
					"body:" => %{
						"application/json:" => %{
							"type:" => "Broadcast"
						}
					}
				},
				"400:" => %{}
			}
		}

		result = SoggyHedgehog.HtmlOutput.sanitize_responses data
		assert length(result) > 0
		[x|result] = result

		assert x.response_code =="200"
		assert x.body =="body"
		assert x.mime_type == "application/json"
		assert x.user_type == "Broadcast"

		[x|result] = result
		assert x.response_code == "400"

	end

	test "sanitize_typename" do
		result = SoggyHedgehog.HtmlOutput.sanitize_typename "Broadcast"
		assert result == "Broadcast"

		result = SoggyHedgehog.HtmlOutput.sanitize_typename "Channel[]"
		assert result == "Channel"
	end

end