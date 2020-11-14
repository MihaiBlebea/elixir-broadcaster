defmodule Broadcaster.Web.Router do
    use Plug.Router

    require Logger

    alias Broadcaster.Controller

    plug Plug.Logger
    plug Plug.Static,
        at: "/",
        from: "./doc"

    plug :match
    plug Plug.Parsers, parsers: [:json], json_decoder: JSON
    plug :dispatch

    get "/test" do
        send_resp(conn, 200, "All working fine")
    end

    post "/save" do
        case conn do
            %{body_params: %{"url" => url}} ->
                url |> Broadcaster.Controller.save_url
                send_resp(conn, 200, "All working fine")
            _ -> send_resp(conn, 500, "Please provide url param in body")
        end
    end

    get "/today" do
        %{params: params} = Plug.Conn.fetch_query_params(conn)

        res = case Map.get(params, "published", nil) do
            nil -> Controller.get_schedule_today
            "true" -> Controller.get_schedule_today
            "false" -> Controller.get_schedule_today
        end

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, JSON.encode!(res))
    end

    post "/publish" do
        res = case conn do
            %{body_params: %{"schedule_id" => _id}} -> Controller.post_scheduled
            _ -> Controller.post_scheduled
        end

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, JSON.encode!(res))
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end
end
