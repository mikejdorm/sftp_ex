defmodule SftpEx.Erl.Sftp do
  @moduledoc "
  A wrapper around the Erlang SFTP library
  "

  alias SFTP.Connection, as: Conn
  alias SftpEx.Types, as: T

  @spec start_channel(T.host(), T.port_number(), list) ::
          {:ok, T.channel_pid(), :ssh.connection_ref()} | T.error_tuple()

  def start_channel(host, port, opts) do
    :ssh_sftp.start_channel(host, port, opts)
  end

  @spec stop_channel(Conn.t()) :: :ok

  def stop_channel(%Conn{} = conn) do
    :ssh_sftp.stop_channel(conn.channel_pid)
  end

  @spec rename(Conn.t(), charlist, charlist, timeout) :: :ok | T.error_tuple()

  def rename(%Conn{} = conn, old_name, new_name, timeout \\ Conn.timeout()) do
    :ssh_sftp.rename(conn.channel_pid, old_name, new_name, timeout)
  end

  @spec read_file_info(Conn.t(), charlist, timeout) :: {:ok, T.file_info()} | T.error_tuple()

  def read_file_info(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    :ssh_sftp.read_file_info(conn.channel_pid, remote_path, timeout)
  end

  @spec list_dir(Conn.t(), charlist, timeout) :: {:ok, [charlist]} | T.error_tuple()

  def list_dir(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    :ssh_sftp.list_dir(conn.channel_pid, remote_path, timeout)
  end

  @spec delete(Conn.t(), charlist, timeout) :: :ok | T.error_tuple()

  def delete(%Conn{} = conn, file, timeout \\ Conn.timeout()) do
    :ssh_sftp.delete(conn.channel_pid, file, timeout)
  end

  @spec delete_directory(Conn.t(), charlist, timeout) :: :ok | T.error_tuple()

  def delete_directory(%Conn{} = conn, directory_path, timeout \\ Conn.timeout()) do
    :ssh_sftp.del_dir(conn.channel_pid, directory_path, timeout)
  end

  @spec make_directory(Conn.t(), charlist, timeout) :: :ok | T.error_tuple()

  def make_directory(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    :ssh_sftp.make_dir(conn.channel_pid, remote_path, timeout)
  end

  @spec close(Conn.t(), T.handle(), timeout) :: :ok | T.error_tuple()

  def close(%Conn{} = conn, handle, timeout \\ Conn.timeout()) do
    :ssh_sftp.close(conn.channel_pid, handle, timeout)
  end

  @spec open(Conn.t(), list, T.mode(), timeout) :: {:ok, T.handle()} | T.error_tuple()

  def open(%Conn{} = conn, remote_path, mode, timeout \\ Conn.timeout()) do
    :ssh_sftp.open(conn.channel_pid, remote_path, mode, timeout)
  end

  @spec open_directory(Conn.t(), list, timeout) :: {:ok, T.handle()} | T.error_tuple()

  def open_directory(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    :ssh_sftp.opendir(conn.channel_pid, remote_path, timeout)
  end

  @spec read(Conn.t(), T.handle(), non_neg_integer, timeout) ::
          {:ok, T.data()} | :eof | T.error_tuple()

  def read(%Conn{} = conn, handle, byte_length, timeout \\ Conn.timeout()) do
    :ssh_sftp.read(conn.channel_pid, handle, byte_length, timeout)
  end

  @spec write(Conn.t(), T.handle(), iodata, timeout) :: :ok | T.error_tuple()

  def write(%Conn{} = conn, handle, data, timeout \\ Conn.timeout()) do
    :ssh_sftp.write(conn.channel_pid, handle, data, timeout)
  end

  @spec write_file(Conn.t(), charlist, iodata, timeout) :: :ok | T.error_tuple()

  def write_file(%Conn{} = conn, remote_path, data, timeout \\ Conn.timeout()) do
    :ssh_sftp.write_file(conn.channel_pid, remote_path, data, timeout)
  end

  @spec read_file(Conn.t(), charlist, timeout) :: {:ok, T.data()} | T.error_tuple()

  def read_file(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    :ssh_sftp.read_file(conn.channel_pid, remote_path, timeout)
  end

  @spec position(Conn.t(), T.handle(), T.location(), timeout) ::
          {:ok, non_neg_integer()} | T.error_tuple()

  def position(%Conn{} = conn, handle, location, timeout \\ Conn.timeout()) do
    :ssh_sftp.position(conn.channel_pid, handle, location, timeout)
  end

  @spec pread(Conn.t(), T.handle(), non_neg_integer(), non_neg_integer(), timeout) ::
          {:ok, T.data()} | :eof | T.error_tuple()

  def pread(%Conn{} = conn, handle, position, length, timeout \\ Conn.timeout()) do
    :ssh_sftp.pread(conn.channel_pid, handle, position, length, timeout)
  end

  @spec pwrite(Conn.t(), T.handle(), non_neg_integer(), T.data(), timeout) :: :ok | T.error_tuple()

  def pwrite(%Conn{} = conn, handle, position, data, timeout \\ Conn.timeout()) do
    :ssh_sftp.pwrite(conn.channel_pid, handle, position, data, timeout)
  end
end
