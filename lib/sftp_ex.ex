defmodule SftpEx do
  @moduledoc """
  Functions for transferring and managing files through SFTP
  """

  alias SFTP.Connection, as: Conn
  alias SftpEx.Sftp.Access
  alias SftpEx.Sftp.Management
  alias SftpEx.Sftp.Stream
  alias SftpEx.Sftp.Transfer
  alias SftpEx.Types, as: T

  @default_opts [
    user_interaction: false,
    silently_accept_hosts: true,
    rekey_limit: 1_000_000_000_000,
    port: 22,
    # port: Application.get_env(:sftp_ex, :port, 22),
    # host: Application.get_env(:sftp_ex, :host) |> T.charlist(),
    # user: Application.get_env(:sftp_ex, :user) |> T.charlist(),
    # password: Application.get_env(:sftp_ex, :password) |> T.charlist(),
    key_cb: SftpEx.KeyProvider
  ]

  @valid_keys [:port, :host, :user, :password]

  @doc """
    Creates a SFTP.Connection struct if the connection is successful,
    else will return {:error, reason}

    A connection struct will contain the
      channel_pid = pid()
      connection_pid = pid()
      host = charlist() | binary()
      port = charlist() | binary()
      opts = [{:option, :value}]

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

    Returns {:ok, SFTP.Connection.t()} | {:error, reason}
  """

  @spec connect(keyword) :: {:ok, Conn.t()} | T.error_tuple()

  def connect(opts \\ []) do
    opts = (@default_opts ++ config_opts()) |> Keyword.merge(opts)
    own_keys = [:host, :port]
    ssh_opts = opts |> Enum.filter(fn {k, _} -> k not in own_keys end)
    Conn.connect(opts[:host], opts[:port], ssh_opts)
  end

  defp config_opts do
    Application.get_all_env(:sftp_ex)
    |> Enum.filter(fn
      {key, _v} when key in @valid_keys -> true
      _ -> false
    end)
    |> Enum.map(fn
      {key, value} when is_binary(value) -> {key, T.charlist(value)}
      kv -> kv
    end)
  end

  @doc """
    Download a file or directory given the connection and remote_path

    Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist()

     Optional: timeout = integer()

    Returns [T.data()] or [[T.data()]] or {:error, reason}
  """

  @spec download(Conn.t(), T.either_string(), timeout()) ::
          [T.data()] | [[T.data()]] | T.error_tuple()

  def download(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    Transfer.download(conn, remote_path, timeout)
  end

  @doc """
    Uploads data to a remote path via SFTP

    Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist()
     file_handle = T.handle()

     Optional: timeout = integer()

    Returns :ok or {:error, reason}
  """

  @spec upload(Conn.t(), T.either_string(), T.handle(), timeout()) :: :ok | T.error_tuple()

  def upload(%Conn{} = conn, remote_path, file_handle, timeout \\ Conn.timeout()) do
    Transfer.upload(conn, remote_path, file_handle, timeout)
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
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist()

     Optional: timeout = integer()

    Returns SftpEx.Sftp.Stream.t()
  """

  @spec stream!(Conn.t(), T.either_string(), non_neg_integer()) :: Stream.t()

  def stream!(%Conn{} = conn, remote_path, byte_size \\ 32768) do
    Stream.new(conn, remote_path, byte_size)
  end

  @doc """
    Opens a file or directory given a connection and remote_path

   Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist()

     Optional: timeout = integer()

    Returns {:ok, T.handle()} or {:error, reason}
  """

  @spec open(Conn.t(), T.either_string(), timeout()) :: {:ok, T.handle()} | T.error_tuple()

  def open(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    Access.open(conn, remote_path, [:read, :binary], timeout)
  end

  @doc """
    Lists the contents of a directory given a connection a handle or remote path

    Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist()

     Optional: timeout = integer()

    Returns {:ok, [Filename]}, or {:error, reason}
  """

  @spec ls(Conn.t(), T.either_string(), timeout()) :: {:ok, list()} | T.error_tuple()

  def ls(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    Management.list_files(conn, remote_path, timeout)
  end

  @doc """
    Lists the contents of a directory given a connection a handle or remote path
    Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist()

     Optional: timeout = integer()

    Returns :ok or {:error, reason}
  """

  @spec mkdir(Conn.t(), T.either_string(), timeout()) :: {:ok, list()} | T.error_tuple()

  def mkdir(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    Management.make_directory(conn, remote_path, timeout)
  end

  @doc """
   Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist() or T.handle()

     Optional: timeout = integer()

     Returns {:ok, File.Stat.t()}, or {:error, reason}
  """

  @spec lstat(Conn.t(), T.either_string() | T.handle(), timeout()) ::
          {:ok, File.Stat.t()} | T.error_tuple()

  def lstat(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    Access.file_info(conn, remote_path, timeout)
  end

  @doc """
  Size of the file in bytes
   Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist() or T.handle()

     Optional: timeout = integer()

   Returns size as {:ok, integer()} or {:error, reason}
  """

  @spec size(Conn.t(), T.either_string(), timeout()) :: {:ok, integer()} | T.error_tuple()

  def size(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    case Access.file_info(conn, remote_path, timeout) do
      {:error, reason} -> {:error, reason}
      {:ok, info} -> info.size
    end
  end

  @doc """
   Gets the type given a remote path.

   Types:
     connection = SFTP.Connection.t()
     remote_path = String.t() or charlist() or T.handle()

     Optional: timeout = integer()

   type = :device | :directory | :regular | :other | :symlink

   Returns {:ok, type}, or {:error, reason}
  """

  @spec get_type(Conn.t(), T.either_string(), timeout()) :: {:ok, T.file_type({})} | T.error_tuple()

  def get_type(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    case Access.file_info(conn, remote_path, timeout) do
      {:error, reason} -> {:error, reason}
      {:ok, info} -> info.type
    end
  end

  @doc """
  Stops the SSH application

  Types:
    connection = SFTP.Connection.t()

  Returns :ok
  """

  @spec disconnect(Conn.t()) :: :ok

  def disconnect(%Conn{} = conn) do
    Conn.disconnect(conn)
  end

  @doc """
    Removes a file from the server.
    Types:
      connection = SFTP.Connection.t()
      file = String.t() or charlist()

      Optional: timeout = integer()

    Returns :ok, or {:error, reason}
  """

  @spec rm(Conn.t(), T.either_string(), timeout()) :: :ok | T.error_tuple()

  def rm(%Conn{} = conn, file, timeout \\ Conn.timeout()) do
    Management.remove_file(conn, file, timeout)
  end

  @doc """
    Removes a directory and all files within it
    Types:
      connection = SFTP.Connection.t()
      remote_path = String.t() or charlist()

      Optional: timeout = integer()

    Returns :ok or {:error, reason}
  """

  @spec rm_dir(Conn.t(), T.either_string(), timeout()) :: :ok | T.error_tuple()

  def rm_dir(%Conn{} = conn, remote_path, timeout \\ Conn.timeout()) do
    Management.remove_directory(conn, remote_path, timeout)
  end

  @doc """
    Renames a file or directory

    Types:
      connection = SFTP.Connection.t()
      old_name = String.t() or charlist()
      new_name = String.t() or charlist()

      Optional: timeout = integer()

    Returns {:ok, T.handle()} or {:error, reason}
  """

  @spec rename(Conn.t(), T.either_string(), T.either_string(), timeout()) ::
          {:ok, T.handle()} | T.error_tuple()

  def rename(%Conn{} = conn, old_name, new_name, timeout \\ Conn.timeout()) do
    Management.rename(conn, old_name, new_name, timeout)
  end

  @doc """
    Appends a file with more data

    Types:
      connection = SFTP.Connection.t()
      remote_path = String.t() or charlist()
      data = T.data()

      Optional: timeout = integer()

    Returns :ok or {:error, reason}
  """

  @spec append(Conn.t(), T.either_string(), T.data(), timeout()) ::
          {:ok, T.handle()} | T.error_tuple()

  def append(%Conn{} = conn, remote_path, data, timeout \\ Conn.timeout()) do
    Management.append_file(conn, remote_path, data, timeout)
  end
end
