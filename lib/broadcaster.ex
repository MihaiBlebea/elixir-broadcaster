defmodule Broadcaster do
    use Application

    @spec start(any, any) :: {:error, any} | {:ok, pid}
    def start(_type, _args) do
        port = Application.get_env(:broadcaster, :port) |> String.to_integer()

        IO.puts "Application starting on port #{ port }..."

        children = [
            {Plug.Cowboy, scheme: :http, plug: Broadcaster.Web.Router, options: [port: port]},
            Broadcaster.Worker,
            {MyXQL, username: "admin", password: "pass", hostname: "localhost", database: "codebot", name: :broadcaster_db}
        ]

        Supervisor.start_link(children, strategy: :one_for_one)
    end
end
