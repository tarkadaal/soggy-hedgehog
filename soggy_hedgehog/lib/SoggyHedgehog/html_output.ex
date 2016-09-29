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
end