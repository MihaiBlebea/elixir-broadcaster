defmodule Broadcaster.Controller do

    require Logger

    alias Broadcaster.PostRepository

    alias Broadcaster.ImageRepository

    alias Broadcaster.IntroRepository

    alias Broadcaster.ScheduleRepository

    alias Broadcaster.LinkedinPublisher

    @spec save_url(binary) :: any
    def save_url(url) when is_binary(url) do
        url
        |> sanitize_url
        |> Broadcaster.Scraper.scrape
        |> store_post
        |> store_imgs
        |> store_intros
    end

    @spec schedule :: :ok
    def schedule() do
        post = PostRepository.find_least_published
        img = ImageRepository.find_least_published
        intro = IntroRepository.find_least_published

        template = LinkedinPublisher.build_template(%{
            "url" => Map.get(post, "url", "url"),
            "title" => Map.get(post, "title", "title"),
            "description" => Map.get(post, "description", "description"),
            "img" => Map.get(post, "img", Map.get(img, "url")),
            "intro" => Map.get(intro, "text")
        })

        ScheduleRepository.add_schedule(%{
            "post_id" => Map.fetch!(post, "id"),
            "template" => template,
            "platform" => "linkedin"
        })

        post |> Map.fetch!("id") |> PostRepository.increment_publish_count
        img |> Map.fetch!("id") |> ImageRepository.increment_publish_count
        intro |> Map.fetch!("id") |> IntroRepository.increment_publish_count

        Logger.debug inspect(template)
    end

    @spec get_schedule_today :: map | list
    def get_schedule_today(), do: ScheduleRepository.find_scheduled_today()

    @spec post_scheduled :: :ok | :fail
    def post_scheduled() do
        scheduled = ScheduleRepository.find_one_unpublished
        case scheduled do
            [] -> :fail
            scheduled ->
                scheduled
                |> Map.fetch!("template")
                |> LinkedinPublisher.publish
                |> inspect
                |> Logger.debug

                scheduled |> Map.fetch!("id") |> ScheduleRepository.mark_published
        end
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
