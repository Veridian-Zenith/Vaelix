defmodule Sieben.MixProject do
  use Mix.Project

  def project do
    [
      app: :sieben,
      version: "0.0.2",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      package: package()
    ]
  end

  def application do
    [
      mod: {Sieben.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto]
    ]
  end

  defp deps do
    [
      # Core Elixir dependencies
      {:plug_cowboy, "~> 2.7.5"},
      {:jason, "~> 1.4.4"},

      # IPC and Communication
      {:msgpack_elixir, "~> 2.0"},          # double-check the exact library name
      {:elixir_uuid, "~> 1.2.1"},

      # Configuration and State Management
      {:configparser_ex, "~> 4.0"},

      # gRPC and Protobuf support
      {:protobuf, "~> 0.15.0"},

      # Development dependencies
      {:credo, "~> 1.7.13", only: :dev, runtime: false},

      # Testing dependencies
      {:mox, "~> 1.2.0", only: :test}
    ]
  end

  defp releases do
    [
      sieben: [
        include_executables_for: [:unix],
        steps: [:assemble, :strip],
        strip_beams: [keep: ["Elixir.Sieben.Application"]],
        config_providers: [
          {Config.Provider, [path: "${RELEASE_ROOT}/etc/sieben.config"]}
        ],
        overlays: [
          {:copy, "config/prod.exs", "etc/sieben.config"}
        ]
      ]
    ]
  end

  defp package do
    [
      description: "Vaelix Core Elixir Application - Process Supervisor and IPC Hub",
      files: ~w(
        lib/
        config/
        priv/
        mix.exs
        README.md
        LICENSE
        CHANGELOG.md
      ),
      maintainers: ["Dae Euhwa"],
      licenses: ["OSL-3.0"],
      name: "vaelix",
      source_url: "https://github.com/veridian-zenith/vaelix"
    ]
  end
end
