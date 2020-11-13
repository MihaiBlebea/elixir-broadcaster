defmodule Broadcaster.Web.Router do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug Plug.Static,
        at: "/",
        from: "./doc"
    plug :match
    plug :dispatch

    get "/test" do
        send_resp(conn, 200, "All working fine")
    end

    post "/save" do
        {:ok, request, _} = Plug.Conn.read_body(conn)
        request
        |> JSON.decode!
        |> Broadcaster.PostRepository.add_post

        send_resp(conn, 200, "All working fine")
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end
end
