defmodule SftpEx do
  @moduledoc """
  Functions for transferring and managing files through SFTP
  """
  alias SFTP.TransferService
  alias SFTP.ManagementService
  alias SFTP.ConnectionService
  alias SFTP.AccessService

  @default_opts  [user_interaction: false,
                  silently_accept_hosts: true,
                  rekey_limit: 1000000000000,
                  port: 22]

  def logging_functions do
    [disconnectfun: &SftpEx.Helpers.log_disconnect_func/1,
     unexpectedfun: &SftpEx.Helpers.log_unexpected_func/2,
     ssh_msg_debug_fun: &SftpEx.Helpers.ssh_msg_debug_fun/4,
     failfun: &SftpEx.Helpers.log_ssh_fail_func/3,
     connectfun: &SftpEx.Helpers.connect_log_func/3]
  end

  @doc """
    Download a file given the connection and remote_path
    Returns {:ok, data}, {:error, reason}
  """
  def download(connection, remote_path) do
    TransferService.download(connection, remote_path)
  end

  @doc """
    Uploads data to a remote path via SFTP
    Returns :ok, or {:error, reason}
  """
  def upload(connection, remote_path, file_handle) do
    TransferService.upload(connection.channel_pid, remote_path, file_handle)
  end

  @doc """
    Creates a Connection struct if the connection is successful,
    else will return {:error, reason}

    A connection struct will contain the
      channel_pid = pid()
      connection_pid = pid()
      host = string()
      port = integer()
      opts = [{Option, Value}]

    Default values are set for the following options:

    user_interaction: false,
    silently_accept_hosts: true,
    rekey_limit: 1000000000000,
    port: 22

    ***NOTE: The only required option is ':host'

    The rekey_limit value is set at a large amount because the Erlang library creates
    an exception when the server is negotiating a rekey. Setting the value at a high number
    of bytes will avoid a rekey event occurring.

    Other available options can be found at http://erlang.org/doc/man/ssh.html#connect-3

    Returns {:ok, Connection}, or {:error, reason}
  """
  def connect(opts) do
      opts = opts |> Keyword.merge(@default_opts)
                  |> Keyword.merge(logging_functions())
     own_keys = [:host, :port]
     ssh_opts = opts |> Enum.filter(fn({k,_})-> not (k in own_keys) end)
     ConnectionService.connect(opts[:host], opts[:port], ssh_opts)
  end

  @doc """
    Creates an SFTP stream by opening an SFTP connection and opening a file
    in read or write mode.

    Below is an example of reading a file from a server.

    An example of writing a file to a server is the following.

    stream = File.stream!("filename.txt")
        |> Stream.into(SftpEx.stream!(connection,"/home/path/filename.txt"))
        |> Stream.run

    This follows the same pattern as Elixir IO streams so a file can be transferred
    from one server to another via SFTP as follows.

    stream = SftpEx.stream!(connection,"/home/path/filename.txt")
    |> Stream.into(SftpEx.stream!(connection2,"/home/path/filename.txt"))
    |> Stream.run

    Types:
     connection = Connection
     remote_path = string()

    Returns SFTP.Stream
  """
  def stream!(connection, remote_path, byte_size \\ 32768) do
       SFTP.Stream.__build__(connection, remote_path,  byte_size)
  end

  @doc """
    Opens a file or directory given a connection and remote_path

   Types:
     connection = Connection
     handle = handle()
     remote_path = string()

    Returns {:ok, handle}, or {:error, reason}
  """
  def open(connection, remote_path) do
    AccessService.open(connection, remote_path, :read)
  end

  @doc """
    Lists the contents of a directory given a connection a handle or remote path

    Types:
     connection = Connection
     handle = handle()
     remote_path = string()

    Returns {:ok, [Filename]}, or {:error, reason}
  """
  def ls(connection, remote_path) do
    ManagementService.list_files(connection, remote_path)
  end

  @doc """
    Lists the contents of a directory given a connection a handle or remote path
    Types:
     connection = Connection
     remote_path = string()

    Returns :ok, or {:error, reason}
  """
  def mkdir(connection, remote_path) do
    ManagementService.make_directory(connection, remote_path)
  end


  @doc """
   Types:
     connection = Connection
     remote_path = string() or handle()

     Returns {:ok, File.Stat}, or {:error, reason}
  """
  def lstat(connection, remote_path) do
    AccessService.file_info(connection, remote_path)
  end

  @doc """
   Types:
     connection = Connection
     remote_path = handle() or string()

   Returns size as {:ok, integer()} or {:error, reason}
  """
  def size(connection, remote_path) do
    case AccessService.file_info(connection, remote_path) do
      {:error, reason} -> {:error, reason}
      {:ok, info}-> info.size
    end
  end

  @doc """
   Gets the type given a remote path.
   Types:
     connection = Connection
     remote_path = handle() or string()

   type = :device | :directory | :regular | :other

   Returns {:ok, type}, or {:error, reason}
  """
  def get_type(connection, remote_path) do
    case AccessService.file_info(connection, remote_path) do
      {:error, reason} -> {:error, reason}
      {:ok, info} -> info.type
    end
  end

  @doc """
  Stops the SSH application

  Types:
    connection = Connection

  Returns :ok
  """
  def disconnect(connection) do
    ConnectionService.disconnect(connection)
  end

  @doc """
    Removes a file from the server.
    Types:
      connection = Connection
      file = string()

    Returns :ok, or {:error, reason}
  """
  def rm(connection, file) do
    ManagementService.remove_file(connection, file)
  end

  @doc """
    Removes a directory and all files within it
    Types:
      connection = Connection
      remote_path = string()

    Returns :ok, or {:error, reason}
  """
  def rm_dir(connection, remote_path) do
    ManagementService.remove_directory(connection, remote_path)
  end

  @doc """
    Renames a file or directory

    Types:
      connection = Connection
      old_name = string()
      new_name = string()

    Returns {:ok, handle}, or {:error, reason}
  """
  def rename(connection, old_name, new_name) do
      ManagementService.rename(connection, old_name, new_name)
  end
end

defmodule SftpEx.Helpers do
  require Logger

  @moduledoc false

  def handle_error(e) do
    Logger.error "#{inspect e}"
    e
  end

  def log_disconnect_func(reason) do
     Logger.debug "Disconnection occurred due to reason: #{inspect reason}"
  end

  def log_unexpected_func(message, peer) do
     Logger.debug "Unexpected event occurred for peer #{inspect peer} with message: #{inspect message}"
     :report
  end

  def log_ssh_fail_func(user, peer, reason) do
     Logger.debug "Unexpected event occurred for peer #{inspect peer} and #{inspect user} with message: #{inspect reason}"
  end

  def connect_log_func(user, peer, method) do
     Logger.debug "Unexpected event occurred for peer #{inspect peer} and user #{inspect user} with message: #{inspect method}"
  end

  def ssh_msg_debug_fun(connection_ref, always_display, msg, language_tag) do
     Logger.debug "SSH Debug Message from connection: #{inspect connection_ref} with message: #{inspect msg}, always display #{inspect always_display}, language tag: #{inspect language_tag}"
  end
end