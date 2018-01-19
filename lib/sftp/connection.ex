defmodule SFTP.Connection do
  @moduledoc false
  defstruct channel_pid: nil, connection_ref: nil, host: nil, port: 22, opts: []

  @type t :: %__MODULE__{}

  @doc false
  def __build__(channel_pid, connection_ref, host, port, opts) do
    %SFTP.Connection{
      channel_pid: channel_pid,
      connection_ref: connection_ref,
      host: host,
      port: port,
      opts: opts
    }
  end
end
