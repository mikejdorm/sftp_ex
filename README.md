# SftpEx

[![Module Version](https://img.shields.io/hexpm/v/sftp_ex.svg)](https://hex.pm/packages/sftp_ex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/sftp_ex/)
[![Total Download](https://img.shields.io/hexpm/dt/sftp_ex.svg)](https://hex.pm/packages/sftp_ex)
[![License](https://img.shields.io/hexpm/l/sftp_ex.svg)](https://github.com/mikejdorm/sftp_ex/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/mikejdorm/sftp_ex.svg)](https://github.com/mikejdorm/sftp_ex/commits/master)

An Elixir wrapper around the Erlang SFTP application. This allows for the use of Elixir Streams to transfer files via SFTP.

## Installation

The package can be installed by adding `:sftp_ex` to your list of dependencies in `mix.exs` and `mix deps.get` from a terminal:

```elixir
def deps do
  [
    {:sftp_ex, "~> 0.3.0"}
  ]
end
```

## Configurable options

```elixir
config :sftp_ex, :host, "sftp.your.server.com" # no default
config :sftp_ex, :user, "mr_anderson" # no default
config :sftp_ex, :port, 2337 # defaults to 22
config :sftp_ex, :cert, "fake" # no default and you should inject this value
config :sftp_ex, :password, "worst_password_ever" # no default and you should inject this value
config :sftp_ex, :key_cb, YourKeyProvider # only change this if you know what you're doing and you want to handle your key provider yourself
config :sftp_ex, :timeout, 60_000 # defaults to 3_600_000 (an hour), you can set it to :infinity if you really want to
```

## Creating a Connection

The following is an example of creating a connection with a username and password.

```elixir
{:ok, connection} = SftpEx.connect([host: "somehost", user: "someuser", password: "somepassword"])
```

### or

You could put all of these values in config and load them at runtime and start with no args.

```elixir
{:ok, connection} = SftpEx.connect()
```

**Do not** put sensitive information in configs such as passwords or certs. Instead use a file which is not committed to your repo or a secret holding service like Vault. Then you can inject these values at runtime using [`Application.put_env/2`](https://hexdocs.pm/elixir/1.12/Application.html).


Other connection arguments can be found in the [Erlang documentation]("http://erlang.org/doc/man/ssh.html#connect-3").

## Concepts

For some operations you'll need a file handle. To get one use `open/3`:

```elixir
SftpEx.open( conn, "remote_path")
```

Most things that one would think should have a timeout have a timeout. You can use the default one or your own timeout set in config and/or you can put it as an optional final arguent in most function calls.
## Streaming Files

An example of writing a file to a server is the following:

```elixir
stream =
  File.stream!("filename.txt")
  |> Stream.into(SftpEx.stream!(connection,"/home/path/filename.txt"))
  |> Stream.run
```

A file can be downloaded as follows - in this example a remote file "test2.csv" is downloaded to the local file "filename.txt":

```elixir
SftpEx.stream!(connection,"test2.csv") |> Stream.into(File.stream!("filename.txt")) |> Stream.run
```

Or using `Enum.into`:

```elixir
SftpEx.stream!(connection, "test2.csv") |> Enum.into(File.stream!("filename.txt"))
```

This follows the same pattern as Elixir IO streams so a file can be transferred
from one server to another via SFTP as follows.

```elixir
stream =
  SftpEx.stream!(connection,"/home/path/filename.txt")
  |> Stream.into(SftpEx.stream!(connection2,"/home/path/filename.txt"))
  |> Stream.run
```

## Upload a file

```elixir
SftpEx.upload(connection, "remote_path", data)
```

## Download a file

```elixir
SftpEx.download(connection, "remote_path/carrot_recipes.txt")
```

## Download a directory

```elixir
SftpEx.download(connection, "remote_path/cat_vids")
```

## List files in a directory

```elixir
SftpEx.ls(connection, "remote_path/cat_vids")
```

## Make a directory

```elixir
SftpEx.mkdir(connection, "remote_path/cat_vids")
```

## Get file info

```elixir
SftpEx.lstat(connection, "remote_path/cat_vids/cat_on_trampoline.mp4")

## or

SftpEx.lstat(connection, handle)
```

## Get file size

```elixir
SftpEx.size(connection, "remote_path/cat_vids/cat_on_trampoline.mp4")

## or

SftpEx.size(connection, handle)
```

## Get file type eg `:regular` or `:directory`

```elixir
SftpEx.get_type(connection, "remote_path/cat_vids/cat_on_trampoline.mp4")
```

## When you're done, `disconnect`

```elixir
SftpEx.disconnect(connection)
```

## Remove a file from the server

```elixir
SSftpEx.rm(connection, "remote_path/cat_vids/cat_on_trampoline.mp4")
```

## Remove a directory from the server

```elixir
SSftpEx.rm_dir(connection, "remote_path/cat_vids/cat_on_trampoline.mp4")
```

## Rename a directory or file on the server

```elixir
SSftpEx.rm_dir(connection, "remote_path/cat_vids/cat_on_trampoline.mp4", "remote_path/cat_vids/old_cat_on_trampoline.mp4")
```

## Append an existing file

```elixir
SSftpEx.append(connection, "remote_path/cat_vids/cat_on_trampoline.mp4", more_data)
```

## That's not all!

There is a lot of functionality exposed that isn't made available at the highest level that you can still utilize. Just dig into the code a bit and you'll see how.

Also as this is just a wrapper for `:ssh_sftp` you can still use anything in that lib and it will play nice with this one.

## Copyright and License

Copyright (c) 2016 Michael Dorman

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
