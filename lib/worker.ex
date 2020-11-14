defmodule Broadcaster.Worker do
    use Quantum, otp_app: :broadcaster

    alias Broadcaster.Controller

    @spec schedule :: :ok
    def schedule(), do: Controller.schedule

    @spec schedule :: :ok | :fail
    def publish(), do: Controller.post_scheduled
end
