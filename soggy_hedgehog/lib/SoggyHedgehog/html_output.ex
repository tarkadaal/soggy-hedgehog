defmodule SoggyHedgehog.HtmlOutput do

	def render(nil, _) do
		nil
	end

	def render(data, template_path) do
		EEx.eval_file template_path, [data: data]
	end
end