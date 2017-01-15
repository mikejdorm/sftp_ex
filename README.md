# SftpEx

An Elixir wrapper around the Erlang SFTP application. This allows for the use of Elixir Streams to 
transfer files via SFTP. 
 
Example usage: 

An example of writing a file to a server is the following.
    
    stream = File.stream!("filename.txt")
        |> Stream.into(SftpEx.stream!(connection,"/home/path/filename.txt"))
        |> Stream.run
   
A file can be downloaded as follows - in this example a remote file "test2.csv" is downloaded to 
the local file "filename.txt" 

    SftpEx.stream!(connection,"test2.csv") |> Stream.into(File.stream!("filename.txt")) |> Stream.run
    
This follows the same pattern as Elixir IO streams so a file can be transferred
from one server to another via SFTP as follows.

    stream = SftpEx.stream!(connection,"/home/path/filename.txt")
    |> Stream.into(SftpEx.stream!(connection2,"/home/path/filename.txt"))
    |> Stream.run

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `sftp_ex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:sftp_ex, "~> 0.2.0"}]
    end
    ```

  2. Ensure `sftp_ex` is started before your application:

    ```elixir
    def application do
      [applications: [:sftp_ex]]
    end
    ```

