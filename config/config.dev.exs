use Mix.Config

alias Broadcaster.Worker

config :broadcaster,
    mysql_user: "root",
    mysql_password: "root",
    mysql_root: "root",
    mysql_host: "platform-db-db.cap-rover.purpletreetech.com",
    mysql_port: 3306,
    mysql_database: "broadcaster"

# config :broadcaster, Worker,
#     timezone: "Europe/London",
#     timeout: :infinity,
#     jobs: [
#         {"0 6 * * * ", &Worker.schedule/0 },
#         {"0 11 * * *", &Worker.publish/0 }
#     ]
