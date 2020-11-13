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
        end
    end
end
