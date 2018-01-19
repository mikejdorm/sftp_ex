defmodule SSH.ServiceMock do
  @moduledoc false

  def start do
    :ok
  end

  def close_connection(connection) do
    cond do
      connection.host == "testhost" -> :ok
      connection.host == "badhost" -> {:error, "Unable to close connection"}
    end
  end
end
