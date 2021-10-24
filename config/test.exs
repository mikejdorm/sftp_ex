use Mix.Config

config :sftp_ex, :ssh_service, Mock.SftpEx.Ssh
config :sftp_ex, :sftp_service, Mock.SftpEx.Erl.Sftp
