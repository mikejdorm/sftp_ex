defmodule SftpEx.ConnTest do
  @moduledoc false
  use ExUnit.Case, async: false

  import Mox

  alias SFTP.Connection, as: Conn

  @host "testhost"
  @port 22
  @opts []

  test "disconnect" do
    channel_pid = :c.pid(0, 200, 0)
    channel_ref = :c.pid(0, 250, 0)

    conn = Conn.new(channel_pid, channel_ref, @host, @port, @opts)

    Mock.SftpEx.Erl.Sftp
    |> expect(:stop_channel, fn ^conn ->
      :ok
    end)

    Mock.SftpEx.Ssh |> expect(:close_connection, fn ^conn -> :ok end)

    assert :ok == Conn.disconnect(conn)
  end

  test "connect" do
    channel_pid = :c.pid(0, 200, 0)
    channel_ref = :c.pid(0, 250, 0)

    Mock.SftpEx.Erl.Sftp
    |> expect(:start_channel, fn @host, @port, @opts ->
      {:ok, channel_pid, channel_ref}
    end)

    Mock.SftpEx.Ssh |> expect(:start, fn -> :ok end)

    {:ok, connection} = Conn.connect(@host, @port, @opts)
    assert @host == connection.host
    assert @port == connection.port
    assert @opts == connection.opts
  end
end
