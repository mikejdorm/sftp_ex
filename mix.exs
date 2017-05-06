defmodule SftpEx.Mixfile do
  use Mix.Project

  def project do
    [app: :sftp_ex,
     version: "0.2.2",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: "A simple SFTP Elixir library",
     package: package(),
    #docs
    name: "sftp_ex",
    source_url: "https://github.com/mikejdorm/sftp_ex",
    docs: [main: "SftpEx", # The main page in the docs
           extras: ["README.md"]]]
  end

  def application do
    [applications: [:logger, :ssh, :public_key, :crypto]]
  end

  defp deps do
    [{:mock, "~> 0.2.0", only: :test},
     {:ex_doc, "~> 0.14", only: :dev}]
  end

  defp package do
    [maintainers: ["Michael Dorman"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/mikejdorm/sftp_ex"}]
  end
end
