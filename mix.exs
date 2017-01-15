defmodule SftpEx.Mixfile do
  use Mix.Project

  def project do
    [app: :sftp_ex,
     version: "0.2.0",
     elixir: "~> 1.3",
     deps: deps(),
     description: "A simple SFTP Elixir library",
     package: package()
     ]
  end

  def application do
    [applications: [:logger, :ssh, :public_key, :crypto]]
  end

  defp deps do
    [{:mock, "~> 0.2.0", only: :test}]
  end

  defp package do
    [maintainers: ["Michael Dorman"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/mikejdorm/sftp_ex"}]
  end
end
