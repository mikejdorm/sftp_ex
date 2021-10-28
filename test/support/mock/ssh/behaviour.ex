defmodule SftpEx.Ssh.Behaviour do
  @moduledoc false
  # a contract for ssh to fufil, for Mox
  @callback start() :: :ok | {:error, any()}
  @callback close_connection(Conn.t()) :: :ok | {:error, any()}
end
