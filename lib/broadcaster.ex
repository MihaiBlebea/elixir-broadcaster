defmodule Broadcaster do
    use Application

    require Logger

    alias Broadcaster.ScheduleRepository

    @spec start(any, any) :: {:error, any} | {:ok, pid}
    def start(_type, _args) do
        port = Application.get_env(:broadcaster, :port) |> String.to_integer()

        Logger.debug inspect("Application starting on port #{ port } and #{ Mix.env } env...")

        Logger.debug inspect(Application.get_all_env(:broadcaster))

        children = [
            {Plug.Cowboy, scheme: :http, plug: Broadcaster.Web.Router, options: [port: port]},
            Broadcaster.Worker,
            {MyXQL, username: "admin", password: "pass", hostname: "localhost", database: "codebot", name: :broadcaster_db}
        ]

        supervisor = Supervisor.start_link(children, strategy: :one_for_one)

        ScheduleRepository.create_table

        supervisor
    end
end
