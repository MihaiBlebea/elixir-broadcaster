defmodule Broadcaster.ScheduleRepository do

    use Broadcaster.Repository

    @table_name "schedules"

    @db_app :broadcaster_db

    @spec create_table :: :ok | :fail
    def create_table() do
        MyXQL.query(
            @db_app,
            "CREATE TABLE IF NOT EXISTS #{ @table_name } (
                id INT NOT NULL AUTO_INCREMENT,
                post_id INT(5) NOT NULL,
                template TEXT NOT NULL,
                platform VARCHAR(255) NOT NULL,
                published INT(5) DEFAULT 0,
                created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (id)
            )"
        ) |> handle_result
    end

    @spec destory_table :: :ok | :fail
    def destory_table() do
        MyXQL.query(
            @db_app,
            "DROP TABLE #{ @table_name }"
        ) |> handle_result
    end

    @doc """
    **Broadcaster.ScheduleRepository.add_schedule/1**
    ```
    %{
        "post_id" => binary,
        "template" => binary,
        "platform" => binary
    }
    ```
    """
    @spec add_schedule(map) :: :ok | :fail | integer
    def add_schedule(%{"post_id" => post_id, "template" => template, "platform" => platform}) do
        MyXQL.query(
            @db_app,
            "INSERT INTO #{ @table_name } (post_id, template, platform) VALUES (?, ?, ?)",
            [post_id, JSON.encode!(template), platform]
        ) |> handle_result
    end

    @spec mark_published(integer) :: :ok | :fail
    def mark_published(id) do
        MyXQL.query(
            @db_app,
            "UPDATE #{ @table_name } SET published = 1 WHERE id = ?",
            [id]
        ) |> handle_result
    end

    @spec find_scheduled_today :: list | map
    def find_scheduled_today() do
        MyXQL.query(
            @db_app,
            "SELECT * FROM #{ @table_name } WHERE DATE_FORMAT(created, '%Y-%m-%d') = CURRENT_DATE()"
        ) |> handle_result |> cast_json("template")
    end

    @spec find_one_unpublished :: map
    def find_one_unpublished() do
        MyXQL.query(
            @db_app,
            "SELECT * FROM #{ @table_name } WHERE DATE_FORMAT(created, '%Y-%m-%d') = CURRENT_DATE() AND published = 0 LIMIT 1"
        ) |> handle_result |> cast_json("template")
    end
end
