defmodule SFTP.ManagementServiceTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias SFTP.ManagementService

  @host "testhost"
  @port 22
  @opts []
  @test_connection SFTP.Connection.__build__(self(), self(), @host, @port, @opts)

  test "make directory" do
    assert :ok == ManagementService.make_directory(@test_connection, "test/data")
  end

  test "remove directory" do
    assert :ok == ManagementService.remove_directory(@test_connection, "test/testdir")
  end

  test "remove non-existent directory" do
    assert {:error, "Error deleting directory"} ==
             ManagementService.remove_directory(@test_connection, "baddir")
  end

  test "remove file" do
    assert :ok == ManagementService.remove_file(@test_connection, "test/test_file.txt")
  end

  test "remove non-existent file" do
    assert {:error, "Error deleting file"} ==
             ManagementService.remove_file(@test_connection, "bad-file.txt")
  end

  test "rename directory" do
    assert :ok ==
             ManagementService.rename(
               @test_connection,
               "test/data/test_file.txt",
               "test/data/test_file2.txt"
             )
  end

  test "rename non-existent directory" do
    assert {:error, "File not found"} ==
             ManagementService.rename(@test_connection, "bad-file.txt", "bad-file2.txt")
  end
end
