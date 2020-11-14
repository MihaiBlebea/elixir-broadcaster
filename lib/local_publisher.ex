defmodule Broadcaster.LocalPublisher do

    @user_id "urn:li:person:poh_wxCNVI"

    @post_state "PUBLISHED"

    @post_visibility "PUBLIC"

    @spec publish(map) :: nil
    def publish(%{"url" => url, "title" => title, "description" => description, "img" => img, "intro" => intro}) do
        template(url, title, description, img, intro)
        |> JSON.encode!
        |> write("./store/linkedin.json")
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

    defp write(data, path) do
        File.write!(path, data)

        nil
    end
end
