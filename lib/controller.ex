defmodule Broadcaster.Controller do

    @spec save_url(binary) :: any
    def save_url(url) when is_binary(url) do
        url
        |> sanitize_url
        |> Broadcaster.Scraper.scrape
        |> store_post
        |> store_imgs
        |> store_intros
    end

    @spec post_random :: map
    def post_random() do
        post = Broadcaster.PostRepository.find_least_published()
        IO.inspect post
        Broadcaster.LinkedinPublisher.publish(
            %{
                "url" => Map.get(post, "url", "url"),
                "title" => Map.get(post, "title", "title"),
                "description" => Map.get(post, "description", "description"),
                "img" => Map.get(post, "img", "img"),
                "intro" => "intro"
            }
        )
    end

    defp sanitize_url(url) when is_binary(url) do
        url
        |> String.split("?")
        |> Enum.at(0)
        |> String.split("#")
        |> Enum.at(0)
    end

    defp store_post(%{"url" => url, "post" => post, "intros" => _intros, "imgs" => _imgs} = data) do
        post_id =
            %{
                "url" => url,
                "title" => Map.get(post, "title", ""),
                "description" => Map.get(post, "description", ""),
                "img" => Map.get(post, "img", "")
            } |> Broadcaster.PostRepository.add_post

        Map.put(data, "post_id", post_id)
    end

    defp store_imgs(%{"post_id" => id, "url" => _url, "post" => _post, "intros" => _intros, "imgs" => imgs} = data) do
        imgs
        |> Enum.map(fn (img)->
            Broadcaster.ImageRepository.add_image(%{"post_id" => id, "url" => img})
        end)

        data
    end

    defp store_intros(%{"post_id" => id, "url" => _url, "post" => _post, "intros" => intros, "imgs" => _imgs} = data) do
        intros
        |> Enum.map(fn (intro)->
            Broadcaster.IntroRepository.add_intro(%{"post_id" => id, "text" => intro})
        end)

        data
    end
end
