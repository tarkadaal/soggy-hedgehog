defmodule SoggyHedgehog.HtmlOutput do
	require Slime

	def render(nil, _) do
		nil
	end

	def render(data, template_path) do
		File.read!(template_path) |> Slime.render(data: data)
	end
end