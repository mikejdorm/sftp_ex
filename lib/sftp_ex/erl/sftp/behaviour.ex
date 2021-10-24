defmodule SftpEx.Erl.Sftp.Behaviour do
  @moduledoc """
  Use separate module for ease of testing
  """

  alias SftpEx.Conn
  alias SftpEx.Types, as: T

  @callback start_channel(T.host(), T.port_number(), list) ::
              {:ok, T.channel_pid(), :ssh.connection_ref()} | T.error_tuple()

  @callback stop_channel(Conn.t()) :: :ok

  @callback rename(Conn.t(), charlist, charlist, timeout) :: :ok | T.error_tuple()

  @callback read_file_info(Conn.t(), charlist, timeout) :: {:ok, T.file_info()} | T.error_tuple()

  @callback list_dir(Conn.t(), charlist, timeout) :: {:ok, [charlist]} | T.error_tuple()

  @callback delete(Conn.t(), charlist, timeout) :: :ok | T.error_tuple()

  @callback delete_directory(Conn.t(), charlist, timeout) :: :ok | T.error_tuple()

  @callback make_directory(Conn.t(), charlist, timeout) :: :ok | T.error_tuple()

  @callback close(Conn.t(), T.handle(), timeout) :: :ok | T.error_tuple()

  @callback open(Conn.t(), list, atom, timeout) :: {:ok, binary} | T.error_tuple()

  @callback open_directory(Conn.t(), list, timeout) :: {:ok, T.handle()} | T.error_tuple()

  @callback read(Conn.t(), T.handle(), non_neg_integer, timeout) ::
              {:ok, T.data()} | :eof | T.error_tuple()

  @callback write(Conn.t(), T.handle(), iodata, timeout) :: :ok | T.error_tuple()

  @callback write_file(Conn.t(), charlist, iodata, timeout) :: :ok | T.error_tuple()

  @callback read_file(Conn.t(), charlist, timeout) :: {:ok, T.data()} | T.error_tuple()
end
