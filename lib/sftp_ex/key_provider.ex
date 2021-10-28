defmodule SftpEx.KeyProvider do
  @moduledoc """
  Module for making configured private key available for SFTP
  Original source for reference https://gist.github.com/jrissler/1cfa9fab8b55a1004bc74e3bffeb9739
  """

  @behaviour :ssh_client_key_api

  @impl :ssh_client_key_api
  defdelegate add_host_key(host, port, public_key, opts), to: :ssh_file

  @impl :ssh_client_key_api
  defdelegate is_host_key(key, host, port, algorithm, opts), to: :ssh_file

  @impl :ssh_client_key_api
  def user_key(_algorithm, _opts) do
    decoded_pem =
      priv_key()
      |> :public_key.pem_decode()
      |> List.first()

    {:ok, :public_key.pem_entry_decode(decoded_pem)}
  end

  def priv_key do
    Application.get_env(:sftp_ex, :cert)
  end
end
