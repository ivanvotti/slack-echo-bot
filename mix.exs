defmodule Bot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bot,
      version: "0.0.1",
      elixir: "~> 1.2",
      escript: [main_module: Bot.CLI],
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [applications: [:logger, :exjsx, :httpoison, :websocket_client]]
  end

  defp deps do
    [
      {:exjsx, "~> 3.2.0"},
      {:httpoison, "~> 0.8.0"},
      {:websocket_client, github: "jeremyong/websocket_client"}
    ]
  end
end
