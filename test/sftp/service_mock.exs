defmodule SFTP.ServiceMock do
  @moduledoc false

  def binary_data do
    <<131, 104, 3, 100, 0, 1, 97, 100, 0, 1, 98, 100, 0, 1, 99>>
  end

  def start_channel(_host, _port, _opts) do
    {:ok, self(), self()}
  end

  def stop_channel(connection) do
    cond do
      connection.host == "testhost" -> :ok
      connection.host == "badhost" -> {:error, "Unable to stop channel"}
    end
  end

  def rename(_connection, old_name, _new_name) do
    cond do
      old_name == "test/data/test_file.txt" -> :ok
      true -> {:error, "File not found"}
    end
  end

  def read_file_info(_connection, remote_path) do
    IO.puts("Remote Path: #{remote_path}")

    cond do
      remote_path == "test/data/test_file.txt" ->
        :file.read_file_info("test/data/test_file.txt")

      remote_path == "test/data" ->
        :file.read_file_info("test/data")

      true ->
        {:error, "No Such Path"}
    end
  end

  def list_dir(_connection, _remote_path) do
    {:ok, ["test/data/test_file.txt", "test/data/test_file.txt"]}
  end

  def delete(_connection, file) do
    cond do
      file == "test/test_file.txt" -> :ok
      true -> {:error, "Error deleting file"}
    end
  end

  def delete_directory(_connection, file) do
    cond do
      file == "test/testdir" -> :ok
      true -> {:error, "Error deleting directory"}
    end
  end

  def make_directory(_connection, remote_path) do
    cond do
      remote_path == "test/data" -> :ok
      true -> {:error, "Error making directory"}
    end
  end

  def close(_connection, handle) do
    cond do
      handle == "test/data/test_file.txt" -> :ok
      handle == "test/data" -> :ok
      true -> {:error, "Error closing file"}
    end
  end

  def open(_connection, path, _mode) do
    cond do
      path == "test/data/test_file.txt" -> {:ok, :erlang.binary_to_term(binary_data())}
      true -> {:error, "No Such File"}
    end
  end

  def open_directory(_connection, remote_path) do
    IO.puts("Matching on remote_path #{remote_path}")

    cond do
      remote_path == "test/data" -> {:ok, :erlang.binary_to_term(binary_data())}
      true -> {:error, "No Such Directory"}
    end
  end

  def read(connection, _handle, _byte_length) do
    cond do
      connection.host == "testhost" -> {:ok, binary_data()}
      connection.host == "badhost" -> {:error, "Bad connection"}
    end
  end

  def write(connection, _handle, _data) do
    cond do
      connection.host == "testhost" -> :ok
      connection.host == "badhost" -> {:error, "Bad connection"}
    end
  end

  def write_file(connection, _remote_path, _data) do
    cond do
      connection.host == "testhost" -> :ok
      connection.host == "badhost" -> {:error, "Bad connection"}
    end
  end

  def read_file(connection, _remote_path) do
    cond do
      connection.host == "testhost" -> {:ok, binary_data()}
      connection.host == "badhost" -> {:error, "Bad connection"}
    end
  end
end
