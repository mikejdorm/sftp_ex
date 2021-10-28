defmodule SftpEx.Sftp.TransferTest do
  @moduledoc false
  use ExUnit.Case, async: false

  import Mox

  alias SFTP.Connection, as: Conn
  alias SftpEx.Sftp.Access
  alias SftpEx.Sftp.Transfer
  alias SftpEx.Types, as: T

  @host "testhost"
  @port 22
  @opts []
  @test_connection Conn.new(self(), self(), @host, @port, @opts)

  describe "each_binstream/3" do
    test "without errors" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, T.new_file_info()}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:open, fn _conn, 'test/data/test_file.txt', [:read, :binary], _timeout ->
        {:ok, {:a, :b, :c}}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:read, fn _conn, {:a, :b, :c}, 1024, _timeout ->
        data = "run for the hills"
        {:ok, data}
      end)

      assert {:ok, handle} =
               Access.open(@test_connection, "test/data/test_file.txt", [:read, :binary])

      assert {["run for the hills"], ^handle} =
               Transfer.each_binstream(@test_connection, handle, 1024)
    end

    test "with eof" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, T.new_file_info()}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:open, fn _conn, 'test/data/test_file.txt', [:read, :binary], _timeout ->
        {:ok, {:a, :b, :c}}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:read, fn _conn, {:a, :b, :c}, 1024, _timeout ->
        :eof
      end)

      assert {:ok, handle} =
               Access.open(@test_connection, "test/data/test_file.txt", [:read, :binary])

      assert {:halt, ^handle} = Transfer.each_binstream(@test_connection, handle, 1024)
    end

    test "with streaming error" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, T.new_file_info()}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:open, fn _conn, 'test/data/test_file.txt', [:read, :binary], _timeout ->
        {:ok, {:a, :b, :c}}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:read, fn _conn, {:a, :b, :c}, 1024, _timeout ->
        {:error, "I fell off the roof"}
      end)

      assert {:ok, handle} =
               Access.open(@test_connection, "test/data/test_file.txt", [:read, :binary])

      assert_raise IO.StreamError, fn ->
        Transfer.each_binstream(@test_connection, handle, 1024)
      end
    end
  end

  describe "download/3" do
    test "a file" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, T.new_file_info(type: :regular)}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, "some like it hot"}
      end)

      assert ["some like it hot"] = Transfer.download(@test_connection, "test/data/test_file.txt")
    end

    test "a directory" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, T.new_file_info(type: :directory)}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file, fn _conn, 'test/data/test_file1.txt', _timeout ->
        {:ok, "some like it hot"}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file, fn _conn, 'test/data/test_file2.txt', _timeout ->
        {:ok, "some like it cold"}
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:list_dir, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, ['test/data/test_file1.txt', 'test/data/test_file2.txt']}
      end)

      assert [["some like it hot"], ["some like it cold"]] =
               Transfer.download(@test_connection, "test/data/test_file.txt")
    end

    test "not a directory or a file" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
        {:ok, T.new_file_info(type: :symlink)}
      end)

      assert {:error, "Unsupported type: :symlink"} =
               Transfer.download(@test_connection, "test/data/test_file.txt")
    end
  end
end
