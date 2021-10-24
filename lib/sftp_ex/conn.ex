defmodule SftpEx.Conn do
  @moduledoc """
    Provides methods related to starting and stopping an SFTP connection
  """

  require SftpEx.Logger, as: Logger

  alias SftpEx.Types, as: T

  @ssh Application.get_env(:sftp_ex, :ssh_service, SftpEx.Ssh)
  @sftp Application.get_env(:sftp_ex, :sftp_service, SftpEx.Erl.Sftp)

  defstruct channel_pid: nil, connection_ref: nil, host: nil, port: 22, opts: []

  # Default in :ssh_sftp is :infinity... seems like an hour is more reasonable
  # Set it in config if you want something else
  def timeout, do: Application.get_env(:sftp_ex, :timeout, 3_600_000)

  @type t :: %__MODULE__{
          channel_pid: T.channel_pid(),
          connection_ref: T.connection_ref(),
          host: T.host(),
          port: T.port(),
          opts: list()
        }

  @doc """
  Creates a new Conn with given values
  """

  @spec new(pid, :ssh.connection_ref(), T.host(), T.port_number(), list) :: C.t()

  def new(channel_pid, connection_ref, host, port, opts) do
    %__MODULE__{
      channel_pid: channel_pid,
      connection_ref: connection_ref,
      host: host,
      port: port,
      opts: opts
    }
  end

  @doc """
  Stops a SFTP channel and closes the SSH connection.

  Returns :ok
  """

  @spec disconnect(Connection.t()) :: :ok | T.error_tuple()

  def disconnect(conn) do
    @sftp.stop_channel(conn)
    @ssh.close_connection(conn)
  end

  @doc """
  Creates an SFTP connection
  Returns {:ok, Connection}, or {:error, reason}
  """

  @spec connect(T.host(), T.port(), list) :: {:ok, Connection.t()} | T.error_tuple()

  def connect(host, port, opts) do
    @ssh.start()

    case @sftp.start_channel(host, port, opts) do
      {:ok, channel_pid, connection_ref} ->
        {:ok, new(channel_pid, connection_ref, host, port, opts)}

      e ->
        Logger.handle_error([__MODULE__, :connect], e)
    end
  end
end
