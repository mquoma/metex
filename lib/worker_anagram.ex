defmodule Metex.WorkerAnagram do

  def loop() do
    receive do
      {sender_pid, line} ->
        send(sender_pid, (&get/1).(line))
      _ ->
        IO.puts("cannot process this msg")
    end

    loop()
  end

  def get(input) do
    result =
    input
    |> url()
    |> append_api_key()
    |> HTTPoison.get([], [timeout: 50_000, recv_timeout: 50_000])
    |> parse_response()
    {:ok, input, result}
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
