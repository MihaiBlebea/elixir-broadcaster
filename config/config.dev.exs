use Mix.Config

alias Broadcaster.Worker

config :broadcaster,
    linkedin_publisher: Broadcaster.LocalPublisher

config :broadcaster, Worker,
    jobs: [
        # {"* * * * *", &Worker.schedule/0 },
        # {"* * * * *", &Worker.publish/0 }
    ]
