defmodule SoggyHedgehog.Mixfile do
  use Mix.Project

  def project do
    [app: :soggy_hedgehog,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: [main_module: SoggyHedgehog],  # <- add this line
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :eex],
     mod: {SoggyHedgehog, []} ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:mix_test_watch, "~> 0.2.6"},
      {:floki, "~> 0.10.1"},
      {:slime, "~> 0.15.0"}
    ]
  end
end
