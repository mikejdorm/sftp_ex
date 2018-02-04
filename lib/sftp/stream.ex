defmodule SFTP.Stream do
  @moduledoc "
  A stream to download/upload a file from a server through SFTP
  "
  alias SFTP.AccessService, as: AccessSvc
  alias SFTP.TransferService, as: TransferSvc
  alias SFTP.Stream, as: FtpStream

  defstruct connection: nil, path: nil, byte_length: 32768, handle: nil

  @type t :: %__MODULE__{}

  @doc false
  def __build__(connection, path, byte_length) do
    %SFTP.Stream{connection: connection, path: path, byte_length: byte_length}
  end

  defimpl Collectable do
    def into(%FtpStream{connection: connection, path: path, byte_length: byte_length, handle: handle} = stream) do
      into(handle, stream)
    end

    defp into(nil, stream = %FtpStream{connection: connection, path: path}) do
      case AccessSvc.open_file(connection, path, [:write, :binary, :creat]) do
          {:error, reason} -> raise File.Error, reason: reason, action: "stream", path: path
          {:ok, handle} -> {:ok, into(handle, %{stream | handle: handle})}
      end
    end

    defp into(handle, stream = %FtpStream{connection: connection, path: path}) do
      fn
        :ok, {:cont, x} ->
          TransferSvc.write(connection, handle, x)
        :ok, :done ->
          :ok = AccessSvc.close(connection, handle)
          stream
        :ok, :halt ->
          :ok = AccessSvc.close(connection, handle)
      end
    end
  end

  defimpl Enumerable do
    def reduce(stream = %FtpStream{connection: connection, path: path, byte_length: byte_length}, acc, fun) do
      start_function = fn ->
        case AccessSvc.open(connection, path, [:read, :binary]) do
          {:error, reason} -> raise File.Error, reason: reason, action: "stream", path: path
          {:ok, handle} -> %{stream | handle: handle}
        end
      end
      next_function = &TransferSvc.each_binstream(&1)
      close_function = &AccessSvc.close(&1)
      Stream.resource(start_function, next_function, close_function).(acc, fun)
    end

    def count(_stream) do
      {:error, __MODULE__}
    end

    def member?(_stream, _term) do
      {:error, __MODULE__}
    end
  end
end
