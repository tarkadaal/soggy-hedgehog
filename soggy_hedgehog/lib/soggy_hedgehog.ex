defmodule SoggyHedgehog do
  alias SoggyHedgehog.Raml
  alias SoggyHedgehog.HtmlOutput
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: SoggyHedgehog.Worker.start_link(arg1, arg2, arg3)
      # worker(SoggyHedgehog.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SoggyHedgehog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def main(args) do
    option_spec = [raml_path: :string]
    options = OptionParser.parse(args, strict: option_spec)
    start_parse options
  end

  defp start_parse({[raml_path: raml_path],_,_}) do
    start_parse(raml_path, File.exists?(raml_path))
  end

  defp start_parse(_) do
    IO.puts "Invalid options."
  end

  defp start_parse(raml_path, true) do
    raml_path |> File.read! |> Raml.parse |> _start_parse()
  end

  defp _start_parse({:ok, raml}) do
    output = HtmlOutput.render raml
    IO.puts output
  end

  defp _start_parse({:error, message}, _) do
    IO.puts message
  end
end
