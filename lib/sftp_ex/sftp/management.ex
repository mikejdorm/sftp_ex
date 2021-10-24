defmodule SftpEx.Sftp.Management do
  @moduledoc """
  Provides methods for managing files through an SFTP connection
  """

  require SftpEx.Logger, as: Logger
  require Logger

  @sftp Application.get_env(:sftp_ex, :sftp_service, SftpEx.Erl.Sftp)

  alias SftpEx.Conn
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
    case Access.file_info(conn, remote_path, timeout) do
      {:ok, file_info} ->
        case file_info.type do
          :directory ->
            case @sftp.list_dir(conn, T.charlist(remote_path), timeout) do
              {:ok, file_list} ->
                {:ok,
                 Enum.filter(file_list, fn file_name -> file_name != '.' && file_name != '..' end)}

              e ->
                e
            end

          _ ->
            {:error, "Remote path is not a directory"}
        end

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

  defp remove_all_files(%Conn{} = conn, directory, timeout \\ Conn.timeout()) do
    case list_files(conn, T.charlist(directory), timeout) do
      {:ok, filenames} ->
        with :ok <- Enum.each(filenames, &remove_file(conn, "#{directory}/#{&1}")) do
          :ok
        else
          e -> e
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec truncate_file(Conn.t(), T.either_string(), non_neg_integer()) :: [...]
  def truncate_file(%Conn{} = conn, remote_path, bytes) do
    # TODO
    [conn, remote_path, bytes]
  end
end
