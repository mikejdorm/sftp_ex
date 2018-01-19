defmodule SFTP.Service do
  @moduledoc "
  A wrapper around the Erlang SFTP library
  "

  def start_channel(host, port, opts) do
    :ssh_sftp.start_channel(host, port, opts)
  end

  def stop_channel(connection) do
    :ssh_sftp.stop_channel(connection.channel_pid)
  end

  def rename(connection, old_name, new_name) do
    :ssh_sftp.rename(connection.channel_pid, old_name, new_name)
  end

  def read_file_info(connection, remote_path) do
    :ssh_sftp.read_file_info(connection.channel_pid, remote_path)
  end

  def list_dir(connection, remote_path) do
    :ssh_sftp.list_dir(connection.channel_pid, remote_path)
  end

  def delete(connection, file) do
    :ssh_sftp.delete(connection.channel_pid, file)
  end

  def delete_directory(connection, directory_path) do
    :ssh_sftp.del_dir(connection.channel_pid, directory_path)
  end

  def make_directory(connection, remote_path) do
    :ssh_sftp.make_dir(connection.channel_pid, remote_path)
  end

  def close(connection, handle) do
    :ssh_sftp.close(connection.channel_pid, handle)
  end

  def open(connection, remote_path, mode) do
    :ssh_sftp.open(connection.channel_pid, remote_path, mode)
  end

  def open_directory(connection, remote_path) do
    :ssh_sftp.opendir(connection.channel_pid, remote_path)
  end

  def read(connection, handle, byte_length) do
    :ssh_sftp.read(connection.channel_pid, handle, byte_length)
  end

  def write(connection, handle, data) do
    :ssh_sftp.write(connection.channel_pid, handle, data)
  end

  def write_file(connection, remote_path, data) do
    :ssh_sftp.write_file(connection.channel_pid, remote_path, data)
  end

  def read_file(connection, remote_path) do
    :ssh_sftp.read_file(connection.channel_pid, remote_path)
  end
end
