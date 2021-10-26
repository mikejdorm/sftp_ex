defmodule SftpEx.Sftp.Stream do
  @moduledoc "
  A stream to download/upload a file from a server through SFTP
  "

  alias SFTP.Connection, as: Conn
  alias SftpEx.Sftp.Access
  alias SftpEx.Sftp.Stream
  alias SftpEx.Sftp.Transfer
  alias SftpEx.Types, as: T

  defstruct conn: nil, path: nil, byte_length: 32768

  @type t :: %__MODULE__{
          conn: Conn.t(),
          path: T.either_string(),
          byte_length: non_neg_integer
        }

  @spec new(Conn.t(), T.either_string(), non_neg_integer()) :: t
  def new(%Conn{} = conn, path, byte_length) do
    %__MODULE__{conn: conn, path: T.charlist(path), byte_length: byte_length}
  end

  defimpl Collectable do
    @spec into(Stream.t()) :: none
    def into(%Stream{conn: conn, path: path, byte_length: _byte_length} = stream) do
      case Access.open_file(conn, path, [:write, :binary, :creat]) do
        {:ok, handle} -> {:ok, into(conn, handle, stream)}
        {:error, reason} -> {:error, reason}
      end
    end

    defp into(conn, handle, stream) do
      fn
        :ok, {:cont, x} ->
          Transfer.write(conn, handle, x)

        :ok, :done ->
          :ok = Access.close(conn, handle)
          stream

        :ok, :halt ->
          :ok = Access.close(conn, handle)
      end
    end
  end

  defimpl Enumerable do
    @spec reduce(Stream.t(), {:cont, any} | {:halt, any} | {:suspend, any}, fun()) ::
            :badarg | {:halted, any} | {:suspended, any, (any -> any)}
    def reduce(%Stream{conn: conn, path: path, byte_length: byte_length}, acc, fun) do
      start_function = fn ->
        case Access.open(conn, path, [:read, :binary]) do
          {:ok, handle} -> handle
          {:error, reason} -> raise File.Error, reason: reason, action: "stream", path: path
        end
      end

      next_function = &Transfer.each_binstream(conn, &1, byte_length)

      close_function = &Access.close(conn, &1)

      Stream.resource(start_function, next_function, close_function).(acc, fun)
    end

    def count(_stream) do
      {:error, Stream}
    end

    def member?(_stream, _term) do
      {:error, Stream}
    end

    def slice(_stream) do
      {:error, Stream}
    end
  end
end
