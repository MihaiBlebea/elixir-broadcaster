use Mix.Config

alias Broadcaster.Worker

config :broadcaster,
    port: "8080",
    linkedin_token: "AQXddWv4RzR-BIQLGno-mWbqnrgrsL8C_BCXD7a7KgNseXOfMPgH-B3yTu6mNcWOymxCby778ore61fsTG1X4SXoOvHCbelQqZOKIu8cMeXodEMqN1pOrf-iW7nirTA1ryPUb4-jtOVkludJ3nQXN8MvkRHjaKQP1ZHjAPEgs0kvTZjkXo7N1gCzSMTTPP7Gr2KcxAG5h-K56wkoId8l67edSiK4AOf8hixBes3UXv_klUZ9ZoZJ5Ibc7jluDVJ7clrp_fuPMU6n2CrBcFauP0c3iuVJfMa0pDN4mg2pG4kQi3yjk_J0UAM0k854XwSE8XHBw-Q0mxY3KsZAJA2ZV11CtsM7EA",
    linkedin_user: "urn:li:person:poh_wxCNVI",
    mysql_user: "root",
    mysql_password: "root",
    mysql_root: "root",
    mysql_host: "srv-captain--platform-db-db",
    mysql_port: 3306,
    mysql_database: "broadcaster"

config :broadcaster, Worker,
    timeout: :infinity,
    jobs: [
        {"0 11 * * *", &Worker.schedule/0},
        {"0 12 * * *", &Worker.publish/0}
    ]
