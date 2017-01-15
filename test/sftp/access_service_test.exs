defmodule SFTP.AccessServiceTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias SFTP.AccessService

  @host "testhost"
  @port 22
  @opts []
  @test_connection SFTP.Connection.__build__(self(), self(), @host , @port, @opts)

  test "open" do
    { :ok, handle } = AccessService.open(@test_connection, "test/data/test_file.txt", :read)
    assert :erlang.binary_to_term(SFTP.ServiceMock.binary_data()) == handle
  end

  test "open non-existent file" do
    e = AccessService.open(@test_connection, "bad_file.txt", :read)
    assert {:error, "No Such Path"} == e
  end

  test "open_directory" do
    { :ok, handle } = AccessService.open(@test_connection, "test/data", :read)
    assert :erlang.binary_to_term(SFTP.ServiceMock.binary_data()) == handle
  end

  test "close file" do
    assert :ok == AccessService.close(@test_connection,"test/data/test_file.txt")
  end

  test "close non-existent file" do
    assert {:error, "Error closing file"} == AccessService.close(@test_connection, "bad-file.txt")
  end
end