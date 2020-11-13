defmodule Benchmark do

    @task_timeout 30000

    def eval_scraper() do
        :timer.tc(Broadcaster.Scraper, :scrape, ["https://netflixtechblog.com/how-netflix-scales-its-api-with-graphql-federation-part-1-ae3557c187e2"])
        |> fetch_duration
        |> to_seconds
    end

    def eval_scraper(count) when is_integer(count) do
        tasks = for _n <- 1..count, do: eval_scraper()

        tasks
        |> average
    end

    defp average(list) when is_list(list) do
        list
        |> Enum.reduce(0, fn (res, acc)-> res + acc end)
        |> divide(length(list))
        |> Float.ceil(2)
    end

    defp divide(arg_one, arg_two), do: arg_one / arg_two

    defp fetch_duration({duration, _result}) do
        duration
    end

    defp to_seconds(micro_seconds) do
        micro_seconds / 1000000
        |> Float.ceil(2)
    end
end
