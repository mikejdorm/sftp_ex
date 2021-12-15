defmodule SftpEx.Mixfile do
  use Mix.Project

  @source_url "https://github.com/mikejdorm/sftp_ex"
  @version "0.3.0"

  def project do
    [
      app: :sftp_ex,
      name: "sftp_ex",
      version: @version,
      elixir: ">= 1.10.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ],
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger, :ssh, :public_key, :crypto]]
  end

  defp deps do
    [
      {:mox, "~> 1.0.1", only: :test},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      description: "A simple SFTP Elixir library",
      maintainers: ["Michael Dorman"],
      licenses: ["MIT"],
      links: %{GitHub: @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      formatters: ["html"]
    ]
  end
end
