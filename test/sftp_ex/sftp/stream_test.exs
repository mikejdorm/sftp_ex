defmodule SftpEx.Sftp.StreamTest do
  @moduledoc false
  use ExUnit.Case, async: false

  import Mox

  alias SFTP.Connection, as: Conn
  alias SftpEx.Sftp

  @host "testhost"
  @port 22
  @opts []
  @test_connection Conn.new(self(), self(), @host, @port, @opts)

  describe "into/1" do
    test "without errors" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:write, 10, fn _conn, {:a, :b, :c}, int, _timeout when int in 1..10 ->
        :ok
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:close, fn _conn, {:a, :b, :c}, _timeout ->
        :ok
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:open, fn _conn, 'test/data/test_file.txt', [:write, :binary, :creat], _timeout ->
        {:ok, {:a, :b, :c}}
      end)

      assert :ok ==
               1..10
               |> Stream.into(Sftp.Stream.new(@test_connection, 'test/data/test_file.txt', 1064))
               |> Stream.run()
    end

    test "with errors" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:write, 10, fn _conn, {:a, :b, :c}, int, _timeout when int in 1..10 ->
        :ok
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:close, fn _conn, {:a, :b, :c}, _timeout ->
        :ok
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:open, fn _conn, 'test/data/test_file.txt', [:write, :binary, :creat], _timeout ->
        {:ok, {:a, :b, :c}}
      end)

      assert :ok ==
               1..10
               |> Stream.into(Sftp.Stream.new(@test_connection, 'test/data/test_file.txt', 1064))
               |> Stream.run()
    end
  end

  describe "reduce/3" do
    test "without errors" do
      Mock.SftpEx.Erl.Sftp
      |> expect(:write, 20, fn _conn, {:a, :b, :c}, int, _timeout when int in 1..10 ->
        :ok
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:close, 2, fn _conn, {:a, :b, :c}, _timeout ->
        :ok
      end)

      Mock.SftpEx.Erl.Sftp
      |> expect(:open, 2, fn _conn,
                             'test/data/test_file.txt',
                             [:write, :binary, :creat],
                             _timeout ->
        {:ok, {:a, :b, :c}}
      end)

      # Complete the stream
      assert 1..10
             |> Stream.into(Sftp.Stream.new(@test_connection, 'test/data/test_file.txt', 1064))
             |> Enumerable.reduce({:cont, %{}}, fn
               count, acc ->
                 {:cont, acc |> Map.put(count, count)}
             end) ==
               {:done,
                %{
                  1 => 1,
                  2 => 2,
                  3 => 3,
                  4 => 4,
                  5 => 5,
                  6 => 6,
                  7 => 7,
                  8 => 8,
                  9 => 9,
                  10 => 10
                }}

      # Halt the stream
      assert 1..10
             |> Stream.into(Sftp.Stream.new(@test_connection, 'test/data/test_file.txt', 1064))
             |> Enumerable.reduce({:cont, %{}}, fn
               9, acc ->
                 {:halt, acc}

               count, acc ->
                 {:cont, acc |> Map.put(count, count)}
             end) ==
               {:halted,
                %{
                  1 => 1,
                  2 => 2,
                  3 => 3,
                  4 => 4,
                  5 => 5,
                  6 => 6,
                  7 => 7,
                  8 => 8
                }}
    end
  end
end
