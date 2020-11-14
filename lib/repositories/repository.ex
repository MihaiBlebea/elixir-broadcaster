defmodule Broadcaster.Repository do

    defmacro __using__(_args) do
        quote do
            require Logger

            defp handle_result({:ok, result}) do
                case Map.fetch!(result, :last_insert_id) do
                    0 -> :ok
                    nil -> cast({:ok, result})
                    id -> id
                end
            end

            defp handle_result({:error, error}) do
                Logger.debug inspect(error)
                :fail
            end

            defp cast({:ok, %MyXQL.Result{} = result}) do
                %MyXQL.Result{columns: columns, rows: rows} = result
                rows
                |> Enum.map(fn (row)->
                    Enum.zip(columns, row) |> Enum.into(%{})
                end)
                |> Enum.map(fn (model)-> model |> cast_date_time("created") |> cast_date_time("updated") end)
                |> cast_one?
            end

            defp cast({:error, error}) do
                Logger.debug inspect(error)
                :fail
            end

            defp cast_one?(list) when is_list(list) do
                case length(list) do
                    1 -> Enum.at(list, 0)
                    _ -> list
                end
            end

            defp cast_json(result, key) when is_map(result) and is_binary(key) do
                value =
                    Map.fetch!(result, key)
                    |> JSON.decode!

                Map.put(result, key, value)
            end

            defp cast_json(results, key) when is_list(results) and is_binary(key) do
                Enum.map(results, fn (result)-> cast_json(result, key) end)
            end

            defp cast_date_time(model, key) when is_map(model) and is_binary(key) do
                case Map.get(model, key, nil) do
                    nil -> model
                    date -> Map.put(model, key, Elixir.DateTime.to_string(date))
                end
            end
        end
    end
end
