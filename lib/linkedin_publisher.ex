defmodule Broadcaster.LinkedinPublisher do

    require Logger

    @base_url "https://api.linkedin.com/v2"

    @user_id "urn:li:person:poh_wxCNVI"

    @token "AQXddWv4RzR-BIQLGno-mWbqnrgrsL8C_BCXD7a7KgNseXOfMPgH-B3yTu6mNcWOymxCby778ore61fsTG1X4SXoOvHCbelQqZOKIu8cMeXodEMqN1pOrf-iW7nirTA1ryPUb4-jtOVkludJ3nQXN8MvkRHjaKQP1ZHjAPEgs0kvTZjkXo7N1gCzSMTTPP7Gr2KcxAG5h-K56wkoId8l67edSiK4AOf8hixBes3UXv_klUZ9ZoZJ5Ibc7jluDVJ7clrp_fuPMU6n2CrBcFauP0c3iuVJfMa0pDN4mg2pG4kQi3yjk_J0UAM0k854XwSE8XHBw-Q0mxY3KsZAJA2ZV11CtsM7EA"

    @post_state "PUBLISHED"

    @post_visibility "PUBLIC"

    @spec publish(map) :: :ok | :fail
    def publish(%{"url" => url, "title" => title, "description" => description, "img" => img, "intro" => intro}) do
        request_body = template(url, title, description, img, intro) |> JSON.encode!
        %{body: body, status_code: code} = HTTPoison.post!("#{ @base_url }/ugcPosts", request_body, get_default_headers())

        case code do
            200 -> :ok
            _ ->
                Logger.debug inspect(body)
                :fail
        end
    end

    @spec template(binary, binary, binary, binary, binary) :: map
    def template(url, title, description, _img, intro) do
        %{
            "author" => @user_id,
            "lifecycleState" => @post_state,
            "specificContent" => %{
                "com.linkedin.ugc.ShareContent" => %{
                    "media" => [
                        %{
                            "status" => "READY",
                            "title" => %{
                                "text" => title
                            },
                            "description" => %{
                                "text" => description
                            },
                            "originalUrl" => url,
                            # "thumbnails" => [
                            #     %{
                            #         "url" => img
                            #     }
                            # ]
                        }
                    ],
                    "shareCommentary" => %{
                        "attributes" => [],
                        "text" => intro
                    },
                    "shareMediaCategory" => "ARTICLE"
                }
            },
            "visibility" => %{
                "com.linkedin.ugc.MemberNetworkVisibility" => @post_visibility
            }
        }
    end

    defp get_default_headers, do: ["Authorization": "Bearer #{ @token }", "Content-Type": "application/json", "X-Restli-Protocol-Version": "2.0.0"]

    @spec decode_body(binary, integer) :: map | list | :fail
    def decode_body(body, 200), do: JSON.decode! body

    def decode_body(_body, _code), do: :fail
end
