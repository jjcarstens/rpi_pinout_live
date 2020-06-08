defmodule RpiPinoutLive.MixProject do
  use Mix.Project

  @source_url "https://github.com/jjcarstens/rpi_pinout_live"
  @version "0.1.0"

  def project do
    [
      app: :rpi_pinout_live,
      version: @version,
      elixir: "~> 1.9",
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: ["rpi_pinout_live.ex"],
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application, do: []

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:phoenix_live_view, "~> 0.13"}
    ]
  end

  defp description do
    "Phoenix LiveView component to render Raspberry Pi pinout from https://pinout.xyz"
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "rpi_pinout_live.ex"],
      licenses: ["CC-BY-NC-SA-4.0"],
      links: %{"GitHub" => @source_url}
    }
  end
end
