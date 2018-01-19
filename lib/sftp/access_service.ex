require SftpEx.Helpers, as: S
require Logger

defmodule SFTP.AccessService do
  @moduledoc "Functions for accessing files and directories"

  @sftp Application.get_env(:sftp_ex, :sftp_service, SFTP.Service)

  @doc """
  Closes an open file
  Returns :ok, or {:error, reason}
  """
  def close(connection, handle, _path \\ '') do
    case @sftp.close(connection, handle) do
      :ok -> :ok
      e -> S.handle_error(e)
    end
  end

  @doc """
  Returns {:ok, File.Stat}, or {:error, reason}
  """
  def file_info(connection, remote_path) do
    case @sftp.read_file_info(connection, remote_path) do
      {:ok, file_info} -> {:ok, File.Stat.from_record(file_info)}
      e -> S.handle_error(e)
    end
  end

  @doc """
    Opens a file given a channel PID and path.
    {:ok, handle}, or {:error, reason}
  """
  def open(connection, path, mode) do
    case file_info(connection, path) do
      {:ok, info} ->
        case info.type do
          :directory -> open_dir(connection, path)
          _ -> open_file(connection, path, mode)
        end

      e ->
        S.handle_error(e)
    end
  end

  def open_file(connection, remote_path, mode) do
    @sftp.open(connection, remote_path, mode)
  end

  def open_dir(connection, remote_path) do
    case @sftp.open_directory(connection, remote_path) do
      {:ok, handle} -> {:ok, handle}
      e -> S.handle_error(e)
    end
  end

  defp create_file(connection, path) do
    open_file(connection, path, [:creat])
  end
end
