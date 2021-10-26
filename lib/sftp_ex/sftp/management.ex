defmodule SftpEx.Sftp.Management do
  @moduledoc """
  Provides methods for managing files through an SFTP connection
  """

  require SftpEx.Logger, as: Logger
  require Logger

  @sftp Application.get_env(:sftp_ex, :sftp_service, SftpEx.Erl.Sftp)

  alias SFTP.Connection, as: Conn
  alias SftpEx.Sftp.Access
  alias SftpEx.Types, as: T

  @spec make_directory(Conn.t(), T.either_string(), timeout()) :: :ok | T.error_tuple()

  def make_directory(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    case @sftp.make_directory(conn, T.charlist(remote_path), timeout) do
      :ok -> :ok
      e -> Logger.handle_error(e)
    end
  end

  @doc """
  Removes a directory and all files within the directory

  #Deletes a directory specified by Name. The directory must be empty before it can be successfully deleted.

  Types:
    conn = Conn.t()
    directory = string()

   Returns :ok, or {:error, reason}
  """

  @spec remove_directory(Conn.t(), T.either_string(), timeout) :: :ok | T.error_tuple()

  def remove_directory(%Conn{} = conn, directory, timeout \\ Conn.timeout()) do
    case remove_all_files(conn, directory) do
      :ok ->
        case @sftp.delete_directory(conn, T.charlist(directory), timeout) do
          :ok -> :ok
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Removes a file
  Types:
    conn = Conn.t()
    file = string()

  Returns :ok, or {:error, reason}
  """

  @spec remove_file(Conn.t(), T.either_string(), timeout()) :: :ok | T.error_tuple()

  def remove_file(%Conn{} = conn, file, timeout \\ Conn.timeout()) do
    case @sftp.delete(conn, T.charlist(file), timeout) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Lists files in a directory
  """

  @spec list_files(Conn.t(), T.either_string(), timeout()) ::
          {:ok, list} | T.error_tuple()

  def list_files(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    with {:ok, %File.Stat{type: :directory}} <- Access.file_info(conn, remote_path, timeout),
         {:ok, file_list} <- @sftp.list_dir(conn, T.charlist(remote_path), timeout) do
      {:ok, Enum.reject(file_list, &dotted?/1)}
    else
      {:ok, %File.Stat{}} ->
        {:error, "Remote path is not a directory"}

      e ->
        e
    end
  end

  @doc """
  Renames a file or directory,
  Returns {:ok, handle}, or {:error, reason}
  """

  @spec rename(Conn.t(), T.either_string(), T.either_string(), timeout()) ::
          :ok | T.error_tuple()

  def rename(%Conn{} = conn, old_name, new_name, timeout \\ Conn.timeout()) do
    @sftp.rename(conn, T.charlist(old_name), T.charlist(new_name), timeout)
  end

  @doc """
  Append to an existing file
  Returns :ok or {:error, reason}
  """

  @spec append_file(Conn.t(), T.either_string(), T.data(), timeout()) :: :ok | T.error_tuple()

  def append_file(%Conn{} = conn, remote_path, data, timeout \\ Conn.timeout()) do
    # Get the size to know the starting point to append to
    with {:ok, %File.Stat{size: position, type: :regular}} <-
           Access.file_info(conn, remote_path, timeout),
         # Need to get a handle
         {:ok, handle} <- Access.open_file(conn, remote_path, [:append], timeout),
         # Write to the position at the end of the file aka size
         :ok <- @sftp.pwrite(conn, handle, position, data, timeout),
         # Must stop channel for changes to take effect
         :ok <- @sftp.stop_channel(conn) do
      :ok
    end
  end

  defp remove_all_files(%Conn{} = conn, directory, timeout \\ Conn.timeout()) do
    case list_files(conn, T.charlist(directory), timeout) do
      {:ok, filenames} ->
        Enum.each(filenames, &remove_file(conn, "#{directory}/#{&1}"))

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec dotted?(charlist()) :: boolean()
  defp dotted?('.'), do: true
  defp dotted?('..'), do: true
  defp dotted?(_), do: false
end
