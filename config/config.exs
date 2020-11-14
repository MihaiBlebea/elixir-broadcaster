use Mix.Config

alias Broadcaster.Worker

config :broadcaster,
    port: "8081",
    linkedin_publisher: Broadcaster.LinkedinPublisher

config :broadcaster, Worker,
    jobs: [
        # {"0 6 * * * ", &Worker.schedule/0 },
        # {"0 11 * * *", &Worker.publish/0 }
    ]


import_config "config.#{ Mix.env() }.exs"
