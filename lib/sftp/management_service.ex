require SftpEx.Helpers, as: S
require Logger
defmodule SFTP.ManagementService do
  @moduledoc """
  Provides methods for managing files through an SFTP connection
  """
  @sftp Application.get_env(:sftp_ex, :sftp_service, SFTP.Service)
  alias SFTP.AccessService

  def make_directory(connection, remote_path) do
    case @sftp.make_directory(connection, remote_path) do
      :ok -> :ok
      e -> S.handle_error(e)
    end
  end

  @doc """
  Removes a directory and all files within the directory

  #Deletes a directory specified by Name. The directory must be empty before it can be successfully deleted.

  Types:
    connection = Connection
    directory = string()

   Returns :ok, or {:error, reason}
  """
  def remove_directory(connection, directory) do
    remove_all_files(connection, directory)
    case @sftp.delete_directory(connection, directory) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Removes a file
  Types:
    connection = Connection
    file = string()

  Returns :ok, or {:error, reason}
  """
  def remove_file(connection, file) do
    case @sftp.delete(connection, file) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Lists files in a directory
  """
  def list_files(connection, remote_path) do
      case AccessService.file_info(connection, remote_path) do
        {:ok, file_info} -> case file_info.type do
          :directory -> case @sftp.list_dir(connection, remote_path) do
            {:ok, file_list} -> Enum.filter(file_list,
              fn(file_name) -> file_name != '.' && file_name != '..' end)
             e -> S.handle_error(e)
           end
           _ -> {:error, "Remote path is not a directory"}
         end
         e -> S.handle_error(e)
      end
  end

  @doc """
  Renames a file or directory,
  Returns {:ok, handle}, or {:error, reason}
  """
  def rename(connection, old_name, new_name) do
    @sftp.rename(connection, old_name, new_name)
  end

  defp remove_all_files(connection, directory) do
     case list_files(connection, directory) do
      {:ok, filenames} -> Enum.map(filenames, remove_file(connection, &(&1)))
      e -> S.handle_error(e)
     end
  end

  def truncate_file(connection, remote_path, bytes) do
   #TODO
   [connection, remote_path, bytes]
  end
end
