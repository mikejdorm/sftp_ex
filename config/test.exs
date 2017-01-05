use Mix.Config

Code.compiler_options(ignore_module_conflict: true)

Path.wildcard("test/sftp/*mock*")
|> Enum.each(&Code.require_file("../#{&1}", __DIR__))

Path.wildcard("test/ssh/*mock*")
|> Enum.each(&Code.require_file("../#{&1}", __DIR__))

config :sftp_ex, :ssh_service, SSH.ServiceMock
config :sftp_ex, :sftp_service, SFTP.ServiceMock