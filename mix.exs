defmodule DataMorph.Mixfile do
  use Mix.Project

  def project do
    [app: :data_morph,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:csv, "~> 1.4.2"},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:parallel_stream, "~> 1.0.5"},
    ]
  end
end
