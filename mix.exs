defmodule SftpEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sftp_ex,
      version: "0.3.0",
      elixir: ">= 1.10.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A simple SFTP Elixir library",
      package: package(),
      # docs
      name: "sftp_ex",
      source_url: "https://github.com/mikejdorm/sftp_ex",
      # The main page in the docs
      docs: [main: "SftpEx", extras: ["README.md"]]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger, :ssh, :public_key, :crypto]]
  end

  defp deps do
    [
      {:mox, "~> 1.0.1", only: :test},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Michael Dorman"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/mikejdorm/sftp_ex"}
    ]
  end
end
