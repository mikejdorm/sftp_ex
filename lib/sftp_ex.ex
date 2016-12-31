defmodule SftpEx do
  @moduledoc "Library to transfer files through SFTP"
  require Logger

  @doc """
    Download a file given the host, remote_path, and options
  """
  def download(host, remote_path, opts) do
    case SFTP.Service.connect(host, 22, opts) do
      {:ok, pid_map} -> SFTP.Service.read_and_download(pid_map.channel_pid, remote_path)
      e -> Logger.info("Unable to download")
    end
  end

  @doc """
    Uploads a file via SFTP
  """
  def upload(host, remote_path, data,  opts) do
    case SFTP.Service.connect(host, 20, opts) do
        {:ok, pid_map} -> SFTPService.upload(pid_map.channel_pid, remote_path, data)
        e -> Logger.info("Unable to download")
     end
  end

  @doc """
    Creates an SFTP stream by opening an SFTP connection and opening a file
    in read or write mode.

    Below is an example of reading a file from a server.


    An example of writing a file to a server is the following.

    stream = File.stream!("filename.txt")
        |> Stream.into(SftpEx.stream!("server01","/home/path/filename.txt",[]))
        |> Stream.run

    This follows the same pattern as Elixir IO streams so a file can be transferred
    from one server to another via SFTP as follows.

    stream = SftpEx.stream!("server01","/home/path/filename.txt", [])
    |> Stream.into(SftpEx.stream!("server02","/home/path/filename.txt", []))
    |> Stream.run
  """
  def stream!(host, remote_path, opts) do
      case SFTP.Service.connect(host, 22, opts) do
          {:ok, pid_map} -> SFTP.Stream.__build__(pid_map.channel_pid, remote_path, [],  32768)
                e -> Logger.info("Unable to download")
                end
  end
end
