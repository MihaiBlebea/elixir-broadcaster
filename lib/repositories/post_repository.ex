defmodule Broadcaster.PostRepository do

    use Broadcaster.Repository

    @table_name "posts"

    @db_app :broadcaster_db

    @spec create_table :: :ok | :fail
    def create_table() do
        MyXQL.query(
            @db_app,
            "CREATE TABLE IF NOT EXISTS #{ @table_name } (
                id INT NOT NULL AUTO_INCREMENT,
                url VARCHAR(255) NOT NULL,
                title VARCHAR(255),
                description TEXT,
                img VARCHAR(255),
                published INT(5) DEFAULT 0,
                created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                deleted INT(1) DEFAULT 0,
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

    @spec add_post(map) :: :ok | :fail | integer
    def add_post(%{"url" => url, "title" => title, "description" => description, "img" => img}) do
        MyXQL.query(
            @db_app,
            "INSERT INTO #{ @table_name } (url, title, description, img) VALUES (?, ?, ?, ?)",
            [url, title, description, img]
        ) |> handle_result
    end

    @spec increment_publish_count(integer) :: :ok | :fail
    def increment_publish_count(id) do
        MyXQL.query(
            @db_app,
            "UPDATE #{ @table_name } SET published = published + 1 WHERE id = ?",
            [id]
        ) |> handle_result
    end

    @spec find_least_published :: map
    def find_least_published() do
        MyXQL.query(
            @db_app,
            "SELECT * FROM #{ @table_name } WHERE deleted = 0 ORDER BY published ASC LIMIT 1"
        ) |> handle_result
    end
end
