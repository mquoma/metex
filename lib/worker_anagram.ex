defmodule Metex.WorkerAnagram do

  def get(input) do
    input
    |> url()
    |> append_api_key()
    |> HTTPoison.get([], [timeout: 50_000, recv_timeout: 50_000])
    |> IO.inspect()
    |> parse_response()
  end

  defp url(input) do
    # "new.wordsmith.org/anagram/anagram.cgi?t=1&a=n&anagram=#{URI.encode(input)}"
    "www.anagramica.com/best/#{URI.encode(input |> String.slice(0..9))}"
  end

  defp append_api_key(url) do
    "#{url}"
  end

  defp parse_response({:error, resp}) do
      resp
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: status_code}}) do
    case status_code do
      200 ->
        body
        # |> (fn text -> Regex.run(~r/<br>*[A-Za-z]+<br>/, text) end).()
        # |> case do
        #   nil -> "no matches"
        #   list -> list |> List.first()
        # end
        # |> String.replace("<br>", "")
        |> JSON.decode!()
        |> Map.get("best")
      _ ->
        status_code
    end
  end

end
