use Mix.Config

alias Broadcaster.Worker

config :broadcaster,
    port: "8081"

config :broadcaster, Worker,
    jobs: [
        # {"1,30 8-17 * * *", &Worker.tell_joke/0 },
        # {"0 8-17/1 * * *", &Worker.list_tasks/0 }
    ]

import_config "config.#{ Mix.env() }.exs"
