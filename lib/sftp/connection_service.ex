require SftpEx.Helpers, as: S

defmodule SFTP.ConnectionService do
  @moduledoc """
    Provides methods related to starting and stopping an SFTP connection
  """
  @ssh Application.get_env(:sftp_ex, :ssh_service, SSH.Service)
  @sftp Application.get_env(:sftp_ex, :sftp_service, SFTP.Service)

  @doc """
  Stops a SFTP channel and closes the SSH connection.

  Returns :ok
  """
  def disconnect(connection) do
    @sftp.stop_channel(connection)
    @ssh.close_connection(connection)
  end

  @doc """
  Creates an SFTP connection
  Returns {:ok, Connection}, or {:error, reason}
  """
  def connect(host, port, opts) do
    @ssh.start()

    case @sftp.start_channel(host, port, opts) do
      {:ok, channel_pid, connection_ref} ->
        {:ok, SFTP.Connection.__build__(channel_pid, connection_ref, host, port, opts)}

      e ->
        S.handle_error(e)
    end
  end
end
