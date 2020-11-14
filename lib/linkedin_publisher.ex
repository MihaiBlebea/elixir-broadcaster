defmodule Broadcaster.LinkedinPublisher do

    require Logger

    @base_url "https://api.linkedin.com/v2"

    @user_id Application.get_env(:broadcaster, :linkedin_user)

    @token Application.get_env(:broadcaster, :linkedin_token)

    @post_state "PUBLISHED"

    @post_visibility "PUBLIC"

    @spec publish(map) :: :ok | :fail
    def publish(template) do
        template |> inspect |> Logger.debug

        %{body: body, status_code: code} = HTTPoison.post!(
            "#{ @base_url }/ugcPosts",
            JSON.encode!(template),
            get_default_headers()
        )

        case code do
            200 -> :ok
            _ ->
                Logger.debug inspect(body)
                :fail
        end
    end

    @spec build_template(map) :: map
    def build_template(%{"url" => url, "title" => title, "description" => description, "img" => _img, "intro" => intro}) do
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
                        "text" => build_intro(title, intro)
                    },
                    "shareMediaCategory" => "ARTICLE"
                }
            },
            "visibility" => %{
                "com.linkedin.ugc.MemberNetworkVisibility" => @post_visibility
            }
        }
    end

    defp build_intro(title, intro) do
        "#{ title } \n #{ intro }"
    end

    defp get_default_headers, do: ["Authorization": "Bearer #{ @token }", "Content-Type": "application/json", "X-Restli-Protocol-Version": "2.0.0"]

    @spec decode_body(binary, integer) :: map | list | :fail
    def decode_body(body, 200), do: JSON.decode! body

    def decode_body(_body, _code), do: :fail
end
