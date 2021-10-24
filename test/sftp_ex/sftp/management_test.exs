defmodule SftpEx.Sftp.ManagementTest do
  @moduledoc false
  use ExUnit.Case, async: false

  import Mox

  alias SftpEx.Conn
  alias SftpEx.Sftp.Management
  alias SftpEx.Types, as: T

  @host "testhost"
  @port 22
  @opts []
  @test_connection Conn.new(self(), self(), @host, @port, @opts)
  @timeout 2000

  test "make directory" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:make_directory, fn _conn, 'test/data', _timeout ->
      :ok
    end)

    assert :ok == Management.make_directory(@test_connection, "test/data", @timeout)
  end

  test "remove directory" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:delete, fn _conn, 'test/data/test_file.txt', _timeout ->
      :ok
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:list_dir, fn _conn, 'test/data', _timeout ->
      {:ok, ['test_file.txt']}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:read_file_info, fn _conn, 'test/data', _timeout ->
      {:ok, T.new_file_info(type: :directory)}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:delete_directory, fn _conn, 'test/data', _timeout ->
      :ok
    end)

    assert :ok == Management.remove_directory(@test_connection, "test/data", @timeout)
  end

  test "remove non-existent directory" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:list_dir, fn _conn, 'baddir', _timeout ->
      {:error, "No Such Path"}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:read_file_info, fn _conn, 'baddir', _timeout ->
      # This will not return as list_dir errors
      {:ok, T.new_file_info(type: :directory)}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:delete_directory, fn _conn, 'baddir', _timeout ->
      # This will not return as list_dir errors
      :ok
    end)

    assert {:error, "No Such Path"} ==
             Management.remove_directory(@test_connection, "baddir", @timeout)
  end

  test "remove file" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:delete, fn _conn, 'test/test_file.txt', _timeout ->
      :ok
    end)

    assert :ok == Management.remove_file(@test_connection, "test/test_file.txt", @timeout)
  end

  test "remove non-existent file" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:delete, fn _conn, 'bad-file.txt', _timeout ->
      {:error, "Error deleting file"}
    end)

    assert {:error, "Error deleting file"} ==
             Management.remove_file(@test_connection, "bad-file.txt", @timeout)
  end

  test "rename directory" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:rename, fn _conn, 'test/data/test_file.txt', 'test/data/test_file2.txt', _timeout ->
      :ok
    end)

    assert :ok ==
             Management.rename(
               @test_connection,
               "test/data/test_file.txt",
               "test/data/test_file2.txt",
               @timeout
             )
  end

  test "rename non-existent directory" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:rename, fn _conn, 'bad-file.txt', 'bad-file2.txt', _timeout ->
      {:error, "File not found"}
    end)

    assert {:error, "File not found"} ==
             Management.rename(@test_connection, "bad-file.txt", "bad-file2.txt")
  end
end
