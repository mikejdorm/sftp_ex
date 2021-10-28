defmodule SftpEx.Sftp.Transfer do
  @moduledoc """
  Provides data transfer related functions
  """

  require SftpEx.Logger, as: Logger

  alias SFTP.Connection, as: Conn
  alias SftpEx.Types, as: T

  @sftp Application.get_env(:sftp_ex, :sftp_service, SftpEx.Erl.Sftp)

  @doc """
  Similar to IO.each_binstream this returns a tuple with the data
  and the file handle if data is read from the server. If it reaches
  the end of the file then {:halt, handle} is returned where handle is
  the file handle
  """

  @spec each_binstream(Conn.t(), T.handle(), non_neg_integer(), timeout()) ::
          {:halt, T.handle()} | {[T.data()], T.handle()}

  def each_binstream(%Conn{} = conn, handle, byte_length, timeout \\ Conn.timeout()) do
    case @sftp.read(conn, handle, byte_length, timeout) do
      :eof ->
        {:halt, handle}

      {:error, reason} ->
        raise IO.StreamError, reason: reason

      {:ok, data} ->
        {[data], handle}
    end
  end

  @doc """
    Writes data to a open file using the channel PID
  """

  @spec write(Conn.t(), T.handle(), iodata, timeout) :: :ok | T.error_tuple()

  def write(%Conn{} = conn, handle, data, timeout \\ Conn.timeout()) do
    case @sftp.write(conn, handle, data, timeout) do
      :ok -> :ok
      e -> Logger.handle_error(e)
    end
  end

  @doc """
    Writes a file to a remote path given a file, remote path, and connection.
  """

  @spec upload(Conn.t(), T.either_string(), T.data(), timeout()) :: :ok | T.error_tuple()

  def upload(%Conn{} = conn, remote_path, data, timeout \\ Conn.timeout()) do
    case @sftp.write_file(conn, T.charlist(remote_path), data, timeout) do
      :ok -> :ok
      e -> Logger.handle_error(e)
    end
  end

  @doc """
    Downloads a remote path
    {:ok, data} if successful, {:error, reason} if unsuccessful
  """

  @spec download(Conn.t(), T.either_string(), timeout) ::
          [[T.data()]] | [T.data()] | T.error_tuple()

  def download(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    remote_path = T.charlist(remote_path)

    case @sftp.read_file_info(conn, remote_path, timeout) do
      {:ok, file_stat} ->
        case File.Stat.from_record(file_stat).type do
          :directory -> download_directory(conn, remote_path, timeout)
          :regular -> download_file(conn, remote_path, timeout)
          not_dir_or_file -> {:error, "Unsupported type: #{inspect(not_dir_or_file)}"}
        end

      e ->
        Logger.handle_error(e)
    end
  end

  defp download_file(%Conn{} = conn, remote_path, timeout) do
    case @sftp.read_file(conn, remote_path, timeout) do
      {:ok, data} -> [data]
      e -> Logger.handle_error(e)
    end
  end

  defp download_directory(%Conn{} = conn, remote_path, timeout) do
    case @sftp.list_dir(conn, remote_path, timeout) do
      {:ok, filenames} -> Enum.map(filenames, &download_file(conn, &1, timeout))
      e -> Logger.handle_error(e)
    end
  end
end
