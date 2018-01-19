defmodule SFTP.ConnectionServiceTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias SFTP.ConnectionService

  @host "testhost"
  @port 22
  @opts []
  @test_connection SFTP.Connection.__build__(self(), self(), @host, @port, @opts)

  test "disconnect" do
    assert :ok == ConnectionService.disconnect(@test_connection)
  end

  test "connect" do
    {:ok, connection} = ConnectionService.connect(@host, @port, @opts)
    assert @host == connection.host
    assert @port == connection.port
    assert @opts == connection.opts
  end
end
