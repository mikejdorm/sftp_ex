defmodule SftpEx.Mixfile do
  use Mix.Project

  def project do
    [app: :sftp_ex,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: "A simple SFTP Elixir library"]
  end

  def application do
    [applications: [:logger, :ssh, :public_key, :crypto]]
  end

  defp deps do
    []
  end

  defp package do
    [maintainers: ["Michael Dorman"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/mikejdorm/sftp_ex"}]
  end
end
