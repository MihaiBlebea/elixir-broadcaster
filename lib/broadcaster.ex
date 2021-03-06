defmodule Broadcaster do
    use Application

    require Logger

    alias Broadcaster.PostRepository

    alias Broadcaster.ScheduleRepository

    alias Broadcaster.ImageRepository

    alias Broadcaster.IntroRepository

    @spec start(any, any) :: {:error, any} | {:ok, pid}
    def start(_type, _args) do
        port = Application.get_env(:broadcaster, :port) |> String.to_integer()

        Logger.debug inspect("Application starting on port #{ port }...")

        Logger.debug inspect(Application.get_all_env(:broadcaster))

        children = [
            {Plug.Cowboy, scheme: :http, plug: Broadcaster.Web.Router, options: [port: port]},
            {
                MyXQL,
                # show_sensitive_data_on_connection_error: true,
                username: Application.get_env(:broadcaster, :mysql_user),
                password: Application.get_env(:broadcaster, :mysql_password),
                hostname: Application.get_env(:broadcaster, :mysql_host),
                port: Application.get_env(:broadcaster, :mysql_port),
                database: Application.get_env(:broadcaster, :mysql_database),
                name: :broadcaster_db
            },
            Broadcaster.Worker,
        ]

        supervisor = Supervisor.start_link(children, strategy: :one_for_one)

        migrate_db()

        supervisor
    end

    defp migrate_db() do
        PostRepository.create_table
        ScheduleRepository.create_table
        ImageRepository.create_table
        IntroRepository.create_table
    end
end
