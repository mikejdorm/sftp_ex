defmodule SFTP.Stream do
  @moduledoc "
  A stream to download/upload a file from a server through SFTP
  "
  alias SFTP.AccessService, as: AccessSvc
  alias SFTP.TransferService, as: TransferSvc

  defstruct connection: nil, path: nil, byte_length: 32768

  @type t :: %__MODULE__{}

  @doc false
  def __build__(connection, path, byte_length) do
    %SFTP.Stream{connection: connection, path: path, byte_length: byte_length}
  end

  defimpl Collectable do
    def into(%{connection: connection, path: path, byte_length: byte_length} = stream) do
      case AccessSvc.open(connection, path, :write) do
        {:error, reason} -> {:error, reason}
        {:ok, handle} -> {:ok, into(connection, handle, path, stream)}
      end
    end

    defp into(connection, handle, path, stream) do
      fn
        :ok, {:cont, x} -> TransferSvc.write(connection, handle, x)
        :ok, :done ->
          :ok = AccessSvc.close(connection, handle, path)
          stream
        :ok, :halt ->
          :ok = AccessSvc.close(connection, handle, path)
        {:error, :closed} , {:cont, x} ->
           :ok = AccessSvc.close(connection, handle, path)
        :error, :done ->
           :ok = AccessSvc.close(connection, handle, path)
        :error, :halt ->
             :ok = AccessSvc.close(connection, handle, path)
      end
    end
  end

  defimpl Enumerable do
        def reduce(%{connection: connection, path: path, byte_length: byte_length}, acc, fun) do
          start_function =
            fn ->
               case AccessSvc.open(connection, path, [:read]) do
                  {:error, reason} ->
                      raise File.Error, reason: reason, action: "stream", path: path
                   handle -> handle
               end
             end

          next_function = &TransferSvc.each_binstream(connection, &1, byte_length)

          close_function = &AccessSvc.close(connection, &1, path)

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