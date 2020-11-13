defmodule Broadcaster.MixProject do
    use Mix.Project

    def project do
        [
            app: :broadcaster,
            version: "0.1.0",
            elixir: "~> 1.10",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            elixirc_paths: elixirc_paths(Mix.env)
        ]
    end

    defp elixirc_paths(:test), do: ["lib", "web"]
    defp elixirc_paths(:dev), do: ["lib", "web", "benchmark/benchmark.ex"]
    defp elixirc_paths(_), do: ["lib", "web"]

    # Run "mix help compile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger],
            mod: {Broadcaster, []}
        ]
    end

    # Run "mix help deps" to learn about dependencies.
    defp deps do
        [
            {:plug_cowboy, "~> 2.0"},
            {:httpoison, "~> 1.6", override: true},
            {:json, "~> 1.2"},
            {:ex_doc, "~> 0.22", only: :dev, runtime: false},
            {:quantum, "~> 3.0"},
            {:myxql, "~> 0.4.0"},
            {:floki, "~> 0.29.0"},
            {:fastimage, "~> 1.0.0-rc4"},
        ]
    end
end
