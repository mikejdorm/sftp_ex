defmodule SftpEx.Ssh do
  @moduledoc """
  A wrapper around the Erlang :ssh library
  """

  require SftpEx.Logger, as: Logger

  alias SFTP.Connection, as: Conn
  alias SftpEx.Types, as: T

  @spec start :: :ok | T.error_tuple()
  def start do
    case :ssh.start() do
      :ok -> IO.puts("Connected")
      e -> Logger.handle_error(e)
    end
  end

  @doc """
  Closes a SSH connection
  Returns :ok
  """
  @spec close_connection(Conn.t()) :: :ok | T.error_tuple()
  def close_connection(conn) do
    :ssh.close(conn.connection_ref)
  end
end
