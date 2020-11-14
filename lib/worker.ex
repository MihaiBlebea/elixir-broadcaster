defmodule Broadcaster.Worker do
    use Quantum, otp_app: :broadcaster

    alias Broadcaster.Controller

    def schedule(), do: Controller.schedule

    def publish(), do: Controller.post_scheduled
end
