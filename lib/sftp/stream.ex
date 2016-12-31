defmodule SFTP.Stream do
  require Logger
  @moduledoc "
  A stream to download/upload a file from a server through SFTP
  "

  defstruct channel_pid: nil, path: nil, modes: [], byte_length: 32768

  @type t :: %__MODULE__{}

  @doc false
  def __build__(channel_pid, path, modes, byte_length) do
    %SFTP.Stream{channel_pid: channel_pid, path: path, modes: modes, byte_length: byte_length}
  end

  defimpl Collectable do
    def into(%{channel_pid: channel_pid, path: path, modes: modes} = stream) do
      modes = for mode <- modes, not mode in [:read], do: mode
      case SFTP.Service.open(channel_pid, path, [:write]) do
        {:ok, handle} ->
          {:ok, into(channel_pid, handle, path, stream)}
        {:error, reason} ->
          raise File.Error, reason: reason, action: "stream", path: path
      end
    end

    defp into(channel_pid, handle, path, stream) do
      fn
        :ok, {:cont, x} -> SFTP.Service.write(channel_pid, handle, x)
        :ok, :done ->
          :ok = SFTP.Service.close(channel_pid, handle, path)
          stream
        :ok, :halt ->
          :ok =  SFTP.Service.close(channel_pid, handle, path)
        {:error, :closed} , {:cont, x} ->
           :ok = SFTP.Service.close(channel_pid, handle, path)
        :error, :done ->
           :ok = SFTP.Service.close(channel_pid, handle, path)
        :error, :halt ->
             :ok =  SFTP.Service.close(channel_pid, handle, path)
      end
    end
  end

  defimpl Enumerable do

        def reduce(%{channel_pid: channel_pid, path: path, byte_length: byte_length}, acc, fun) do

          start_function =
            fn ->
               case SFTP.Service.open(channel_pid, path, [:read]) do
                  {:ok, handle} -> handle
                  {:error, reason} ->
                      raise File.Error, reason: reason, action: "stream", path: path
               end
             end

          next_function = &SFTP.Service.each_binstream(channel_pid, &1, byte_length)

          close_function = &SFTP.Service.close(channel_pid, &1, path)

          Stream.resource(start_function, next_function, close_function).(acc, fun)
        end
  end

end