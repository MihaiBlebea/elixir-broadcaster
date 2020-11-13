use Mix.Config

config :codebot,
    port: "8080",
    nlp_module: Codebot.Mock.Witai

config :witai, token: ""
