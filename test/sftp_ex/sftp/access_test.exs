defmodule SftpEx.Sftp.AccessTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import Mox

  alias SftpEx.Sftp.Access
  alias SftpEx.Types, as: T

  @host "testhost"
  @port 22
  @opts []
  @test_connection SFTP.Connection.new(self(), self(), @host, @port, @opts)

  test "open normal file" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:read_file_info, fn _conn, 'test/data/test_file.txt', _timeout ->
      {:ok, T.new_file_info()}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:open, fn _conn, 'test/data/test_file.txt', [:read, :binary], _timeout ->
      {:ok, {:a, :b, :c}}
    end)

    {:ok, handle} = Access.open(@test_connection, "test/data/test_file.txt", [:read, :binary])
    assert :erlang.binary_to_term(binary_data()) == handle
  end

  @tag capture_log: true
  test "open non-existent file" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:read_file_info, fn _conn, 'bad_file.txt', _timeout ->
      {:error, "No Such Path"}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:open, fn _conn, 'bad_file.txt', [:read, :binary], _timeout ->
      {:ok, {:a, :b, :c}}
    end)

    e = Access.open(@test_connection, "bad_file.txt", [:read, :binary])
    assert {:error, "No Such Path"} == e
  end

  test "open_directory returns handle to directory" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:open_directory, fn _conn, 'test/data', _timeout ->
      {:ok, :handle}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:read_file_info, fn _conn, 'test/data', _timeout ->
      {:ok, T.new_file_info()}
    end)

    Mock.SftpEx.Erl.Sftp
    |> expect(:open, fn _conn, 'test/data', [:read, :binary], _timeout ->
      {:ok, {:a, :b, :c}}
    end)

    {:ok, handle} = Access.open(@test_connection, "test/data", [:read, :binary])

    assert :erlang.binary_to_term(binary_data()) == handle
  end

  test "close file" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:close, fn _conn, {:yo, :handle, :can, [be: "anything"]}, _timeout ->
      :ok
    end)

    assert :ok ==
             Access.close(
               @test_connection,
               {:yo, :handle, :can, [be: "anything"]},
               "test/data/test_file.txt"
             )
  end

  @tag capture_log: true
  test "close non-existent file" do
    Mock.SftpEx.Erl.Sftp
    |> expect(:close, fn _conn, "handle", _timeout ->
      {:error, "Error closing file"}
    end)

    assert {:error, "Error closing file"} == Access.close(@test_connection, "handle")
  end

  # {:a, :b, :c} in binary
  def binary_data do
    <<131, 104, 3, 100, 0, 1, 97, 100, 0, 1, 98, 100, 0, 1, 99>>
  end
end
