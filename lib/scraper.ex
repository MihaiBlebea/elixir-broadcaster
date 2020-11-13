defmodule Broadcaster.Scraper do

    @request_timeout 5000

    @p_valid_length 200

    @spec scrape(binary) :: any
    def scrape(url) when is_binary(url) do
        doc =
            url
            |> fetch_content
            |> Floki.parse_document!

        %{
            "url" => url,
            "post" => extract_meta(doc),
            "intros" => extract_p(doc),
            "imgs" => extract_img(doc)
        }
    end

    defp fetch_content(url) do
        options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: @request_timeout, follow_redirect: true]
        %HTTPoison.Response{status_code: code, body: encoded_body} = HTTPoison.get!(url, [], options)

        handle_response(encoded_body, code)
    end

    defp extract_meta(html) do
        html
        |> Floki.find("meta")
        |> normalize_meta
        |> build_post
    end

    defp extract_img(html) do
        html
        |> Floki.find("img")
        |> Enum.map(fn (img)-> Floki.attribute(img, "src") end)
        |> List.flatten
        |> Enum.filter(fn (img)->
            case Fastimage.size(img) do
                {:ok, %Fastimage.Dimensions{height: height, width: width}} -> height > 400 && width > 600
                {:error, _error} -> false
            end
        end)
    end

    defp extract_p(html) do
        html
        |> Floki.find("p")
        |> Enum.map(fn (p)->
            case match?({"p", _attributes, [_text]}, p) do
                false -> nil
                true ->
                    {"p", _attributes, [text]} = p
                    text
            end
        end)
        |> Enum.filter(fn (text)-> is_valid_p(text) end)
    end

    defp is_valid_p(text) do
        text != nil &&
        is_binary(text) &&
        String.length(text) > @p_valid_length &&
        String.contains?(text, ":") == false
    end

    defp handle_response(body, 200) do
        body
    end

    defp handle_response(_body, _code) do
        :fail
    end

    defp normalize_meta(metas) do
        Enum.map(metas, fn (meta)->
            case meta do
                {"meta", content, _value} -> filter_meta(content)
                _ -> nil
            end
        end)
        |> Enum.map(fn (key_value)->
            case key_value do
                [{"property", property}, {"content", content}] -> {property, content}
                [{"name", name}, {"content", content}] -> {name,  content}
                _ -> nil
            end
        end)
        |> Enum.filter(fn (key_value)-> key_value != nil end)
        |> Enum.into(%{})
    end

    defp filter_meta(content) do
        Enum.filter(content, fn (key)-> does_meta_match?(key) end)
    end

    defp does_meta_match?(key_value) do
        match?({"name", _name}, key_value) ||
        match?({"property", _name}, key_value) ||
        match?({"content", _name}, key_value)
    end

    defp build_post(metas) do
        %{
            "title" => Map.get(metas, "og:title", nil),
            "description" => Map.get(metas, "description", nil),
            "image" => Map.get(metas, "og:image", nil),
        }
    end
end
