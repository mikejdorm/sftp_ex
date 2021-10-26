defmodule SftpEx.Sftp.Access do
  @moduledoc """
  Functions for accessing files and directories
  """

  require SftpEx.Logger, as: Logger

  alias SFTP.Connection, as: Conn
  alias SftpEx.Types, as: T

  @sftp Application.get_env(:sftp_ex, :sftp_service, SftpEx.Erl.Sftp)

  @doc """
  Closes an open file
  Returns :ok, or {:error, reason}
  """

  @spec close(Conn.t(), T.handle(), timeout) ::
          :ok | {:error, atom()}

  def close(%Conn{} = conn, handle, timeout \\ Conn.timeout()) do
    case @sftp.close(conn, handle, timeout) do
      :ok -> :ok
      e -> Logger.handle_error(e)
    end
  end

  @doc """
  Returns {:ok, File.Stat}, or {:error, reason}
  """

  @spec file_info(Conn.t(), T.either_string() | T.handle(), timeout) ::
          {:ok, File.Stat.t()} | {:error, atom()}

  def file_info(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    case @sftp.read_file_info(conn, T.charlist_or_handle(remote_path), timeout) do
      {:ok, file_info} -> {:ok, File.Stat.from_record(file_info)}
      e -> Logger.handle_error(e)
    end
  end

  @doc """
    Opens a file or directory given a channel PID and path.
    {:ok, handle}, or {:error, reason}
  """

  @spec open(Conn.t(), T.either_string(), T.mode(), timeout) ::
          {:ok, File.Stat.t()} | {:error, atom()}

  def open(%Conn{} = conn, path, mode, timeout \\ Conn.timeout()) do
    case file_info(conn, T.charlist(path), timeout) do
      {:ok, info} ->
        case info.type do
          :directory -> open_dir(conn, path, timeout)
          _ -> open_file(conn, path, mode, timeout)
        end

      e ->
        Logger.handle_error(e)
    end
  end

  @doc """
    Opens a file  given a channel PID and path.
    {:ok, handle}, or {:error, reason}
  """

  @spec open_file(Conn.t(), T.either_string(), T.mode(), timeout) ::
          {:ok, T.handle()} | T.error_tuple()

  def open_file(%Conn{} = conn, remote_path, mode, timeout \\ Conn.timeout()) do
    @sftp.open(conn, T.charlist(remote_path), mode, timeout)
  end

  @doc """
    Opens a directory  given a channel PID and path.
    {:ok, handle}, or {:error, reason}
  """

  @spec open_dir(Conn.t(), T.either_string(), timeout) ::
          {:ok, T.handle()} | T.error_tuple()

  def open_dir(conn, remote_path, timeout \\ Conn.timeout()) do
    case @sftp.open_directory(conn, T.charlist(remote_path), timeout) do
      {:ok, handle} -> {:ok, handle}
      e -> Logger.handle_error(e)
    end
  end
end
