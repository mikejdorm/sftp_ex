use Mix.Config

config :sftp_ex, :ssh_service, Mock.SftpEx.Ssh
config :sftp_ex, :sftp_service, Mock.SftpEx.Erl.Sftp

config :sftp_ex, :host, "host"
config :sftp_ex, :port, 22
config :sftp_ex, :user, "user"

config :sftp_ex, :cert, "fake"
