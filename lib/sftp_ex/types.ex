defmodule SftpEx.Types do
  @moduledoc """
  All the types and things to deal with types
  """

  # Errors

  @type reason :: atom | charlist | tuple | binary

  @type error_tuple :: {:error, reason}

  # Data Types

  @type host :: charlist | ip_address | :loopback

  @type hostname :: atom | charlist

  @type ip_address :: ip4_address | ip6_address

  @type ip4_address :: {0..255, 0..255, 0..255, 0..255}

  @type ip6_address ::
          {0..65535, 0..65535, 0..65535, 0..65535, 0..65535, 0..65535, 0..65535, 0..65535}

  @type port_number :: 0..65535

  @type channel_pid :: pid

  @type handle :: term()

  @type data :: charlist | binary

  @type either_string :: binary() | charlist()

  # Default is bof - beginning of file | cur - current cursor position | eof - end of file
  # You can specify where you want to place the cursor
  @type location :: integer() | {:bof, integer()} | {:cur, integer()} | {:eof, integer()}

  # 'creat' short for 'creatine' I suspect... you can use it to create a file too though
  @type mode :: [:read | :write | :creat | :trunc | :append | :binary | :raw]

  @type file_type :: :device | :directory | :regular | :other | :symlink

  # file_info{size = integer() >= 0 | undefined,
  #   type =
  #       device | directory | other | regular |
  #       symlink | undefined,
  #   access =
  #       read | write | read_write | none | undefined,
  #   atime =
  #       file:date_time() |
  #       integer() >= 0 |
  #       undefined,
  #   mtime =
  #       file:date_time() |
  #       integer() >= 0 |
  #       undefined,
  #   ctime =
  #       file:date_time() |
  #       integer() >= 0 |
  #       undefined,
  #   mode = integer() >= 0 | undefined,
  #   links = integer() >= 0 | undefined,
  #   major_device = integer() >= 0 | undefined,
  #   minor_device = integer() >= 0 | undefined,
  #   inode = integer() >= 0 | undefined,
  #   uid = integer() >= 0 | undefined,
  #   gid = integer() >= 0 | undefined}

  # To convert back and forth use File.Stat.from_record() and File.Stat.to_record()

  @type file_info :: :file.file_info()

  def new_file_info(opts \\ []) do
    {
      :file_info,
      opts[:size] || :undefined,
      opts[:type] || :undefined,
      opts[:access] || :undefined,
      opts[:atime] || :undefined,
      opts[:mtime] || :undefined,
      opts[:ctime] || :undefined,
      opts[:mode] || :undefined,
      opts[:links] || :undefined,
      opts[:major_device] || :undefined,
      opts[:minor_device] || :undefined,
      opts[:inode] || :undefined,
      opts[:uid] || :undefined,
      opts[:gid] || :undefined
    }
  end

  @doc """
  Erlang likes charlists and Elixir likes binary strings
  Either one fed in gets turned into charlist for Erlang consumption
  """
  @spec charlist(either_string) :: charlist
  def charlist(string) when is_binary(string), do: String.to_charlist(string)
  # Throw error if it doesn't fit
  def charlist(string) when is_list(string), do: string

  @spec charlist_or_handle(either_string) :: charlist | handle()
  def charlist_or_handle(string) when is_binary(string), do: String.to_charlist(string)
  # Super permissive as handle can be anything
  def charlist_or_handle(string), do: string
end
