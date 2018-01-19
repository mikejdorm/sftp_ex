require SftpEx.Helpers, as: S
require Logger

defmodule SSH.Service do
  @moduledoc """
  A wrapper around the Erlang :ssh library
  """

  def start do
    case :ssh.start() do
      :ok -> Logger.info("Connected")
      e -> S.handle_error(e)
    end
  end

  @doc """
  Closes a SSH connection
  Returns :ok
  """
  def close_connection(connection) do
    :ssh.close(connection.connection_ref)
  end
end
