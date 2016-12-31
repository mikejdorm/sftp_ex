defmodule SFTP.Service do
  require Logger
  @moduledoc "
  Provides methods for connecting to a server through SFTP, and
  downloading files from the server.
  "

  @doc """
  Similar to IO.each_binstream this returns a tuple with the data
  and the file handle if data is read from the server. If it reaches
  the end of the file then {:halt, handle} is returned where handle is
  the file handle
  """
  def each_binstream(channel_pid, handle, byte_length) do
    case :ssh_sftp.read(channel_pid, handle, byte_length) do
      :eof ->
        {:halt, handle}
      {:error, reason} ->
        raise IO.StreamError, reason: reason
      data ->
        {[data], handle}
    end
  end

  @doc """
  Creates an SFTP connection

  Available Options see http://erlang.org/doc/man/ssh.html#connect-3
  """
  def connect(host, port, opts) do
    start_ssh
    opts = opts |> Keyword.merge([user_interaction: false,
                                  silently_accept_hosts: true,
                                  disconnectfun: &log_disconnect_func/1,
                                  unexpectedfun: &log_unexpected_func/2,
                                  rekey_limit: 1000000000000])
    Logger.info "Connecting to #{host} with opts #{inspect opts}"
    case :ssh_sftp.start_channel(host, port, opts) do
      {:ok, channel_pid, connection_pid} -> {:ok, %{channel_pid: channel_pid, connection_pid: connection_pid}}
      e -> handle_error(e)
    end
  end

  @doc """
    Closes an open SFTP channel given a channel_pid and file handle
  """
  def close(channel_pid, handle, path) do
    Logger.info "Closing file #{path}"
    :ok
     case :ssh_sftp.close(channel_pid,handle) do
         :ok -> :ok
         {:error, reason} -> raise File.Error, reason: reason, action: "stream", path: path
     end
  end

  @doc """
    Opens a file given a channel PID and path.
    {:ok, handle} if successful, {:error, reason} otherwise
  """
  def open(channel_pid, path, opts) do
    Logger.info "Opening file #{path} for write"
    case :ssh_sftp.open(channel_pid, path, opts) do
      {:ok, handle} -> {:ok, handle}
      e -> handle_error(e)
    end
  end

  @doc """
    Downloads a remote path
    {:ok, data} if successful, {:error, reason} if unsuccessful
  """
  def read_and_download(channel_pid, remote_path) do
     case :ssh_sftp.read_file_info(channel_pid, remote_path) do
       {:ok, file_info} ->
          case File.Stat.from_record(file_info).type do
            :directory -> download_directory(channel_pid, remote_path)
            :regular -> download_file(channel_pid, remote_path)
           _ ->  {:error, "Unsupported Operation"}
          end
        e -> handle_error(e)
      end
  end

  @doc """
    Writes data to a open file using the channel PID
  """
  def write(channel_pid, handle, data) do
    case :ssh_sftp.write(channel_pid, handle, data) do
      :ok -> :ok
      e -> handle_error(e)
    end
  end

  @doc """
    Writes a file to a remote path given a file, path, and open channel
  """
  def upload(channel_pid, remote_path, file) do
    case :ssh_sftp.write_file(channel_pid, remote_path, file) do
      :ok -> :ok
      e -> handle_error(e)
    end
  end

  defp download_file(channel_pid, remote_file) do
    case :ssh_sftp.read_file(channel_pid, remote_file) do
      {:ok, data} -> [data]
      e -> handle_error(e)
    end
  end

  defp download_directory(channel_pid, remote_path) do
    case :ssh_sftp.list_dir(channel_pid, remote_path) do
      {:ok, filenames} -> Enum.map(filenames, &(download_file(channel_pid, &1)))
      e -> handle_error(e)
    end
  end

  defp disconnect_channel(channel_pid) do
    :ssh_sftp.stop_channel(channel_pid)
  end

  defp handle_error(e) do
    Logger.info "#{inspect e}"
    e
  end

  defp start_ssh do
      case  :ssh.start do
       {:ok} -> Logger.info "Connected"
       e -> handle_error(e)
       end
  end

  defp log_disconnect_func(reason) do
     Logger.info "Disconnection occurred due to reason: #{inspect reason}"
  end

  defp log_unexpected_func(message, peer) do
     Logger.info "Unexpected event occurred for peer #{inspect peer} with message: #{inspect message}"
     :report
  end

  defp log_ssh_fail_func(user, peer, reason) do
    #todo
  end

  defp connect_log_func(user, peer, method) do
    #todo
  end

  defp disconnect_log_func(reason) do
    #todo
  end

  defp ssh_msg_debug_fun(connection_ref, msg, language_tag) do
    #todo
  end
end