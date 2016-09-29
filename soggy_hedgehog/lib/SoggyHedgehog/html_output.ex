defmodule SoggyHedgehog.HtmlOutput do
	require EEx
	@main_template "template.eex"
	@endpoint_template "endpoint.eex"

	EEx.function_from_file :defp, :_render, @main_template, [:data]
	EEx.function_from_file :def, :render_endpoints, @endpoint_template, [:map]

	def render(nil) do
		nil
	end

	def render(data) do
		_render data
	end

	def sanitize_responses(data) do
		if is_map(data) and Map.has_key?(data, "responses:") do
			Enum.sort(_sanitize_responses(data["responses:"], []),
				&(&1.response_code <= &2.response_code)
			)
		else
			[]
		end
	end

	defp _sanitize_responses(map, acc) when map_size(map) == 0 do
		acc
	end

	defp _sanitize_responses(responses, acc) do
		key = responses |> Map.keys |> hd
		value = responses[key]

		_sanitize_responses(Map.delete(responses, key), [_sanitize_response(key, value)| acc])
	end

	defp _sanitize_response(response_code, response) do
		response_code = response_code |> remove_end_colon
		body = "body"
		mime_type = response["body:"] 
		mime_type = if is_map(mime_type), do: mime_type |> Map.keys |> hd |> remove_end_colon, else: nil
		user_type = get_in(response, ["body:", "application/json:", "type:"])
		%{response_code: response_code, body: body, mime_type: mime_type, user_type: user_type}
	end

	def sanitize_typename(typename) do
		String.replace_trailing typename, "[]", ""
	end

	defp remove_end_colon(s) do
		String.replace_trailing(s, ":", "")
	end
end