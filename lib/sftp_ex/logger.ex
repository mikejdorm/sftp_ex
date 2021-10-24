defmodule SftpEx.Logger do
  require Logger

  @moduledoc false

  def handle_error(error, meta \\ []) do
    Logger.error("#{inspect(error: error, meta: meta)}")
    error
  end
end
