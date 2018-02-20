defmodule Metex.Worker do

  def loop_forecast() do
    receive do
      {sender_pid, city} ->
        send(sender_pid, (&get/2).(:forecast, city))
      _ ->
        IO.puts("cannot process this msg")
    end

    loop_forecast()
  end

  def loop_temperature() do
    receive do
      {sender_pid, city} ->
        send(sender_pid, (&get/2).(:temperature, city))
      _ ->
        IO.puts("cannot process this msg")
    end

    loop_temperature()
  end

  def get(prop, city) do
    city
    |> url_for(prop)
    |> append_api_key()
    |> HTTPoison.get()
    |> parse_response(prop)
    |> Tuple.append(city)
  end

  defp url_for(city, prop) do
    city = URI.encode(city)

    case prop do
      :temperature ->
        "api.openweathermap.org/data/2.5/weather?q=#{city}"

      :forecast ->
        "api.openweathermap.org/data/2.5/forecast?q=#{city}&mode=json"
    end
  end

  defp append_api_key(url) do
    "#{url}&appid=#{api_key()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}, prop) do
    results =
      body
      |> JSON.decode!()

    case prop do
      :temperature ->
        results |> compute_temperature()

      :forecast ->
        results |> compute_forecast()
    end
  end

  defp parse_response(_resp, _prop) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temperature =
        (json["main"]["temp"] - 273.15)
        |> Float.round(1)

      {:ok, :temperature, temperature}
    rescue
      _ -> :error
    end
  end

  defp compute_forecast(json) do
    try do
      forecast =
        json["list"]
        |> List.first()

      {:ok, :forecast,
       (forecast["main"]["temp"] - 273.15)
       |> Float.round(1)}
    rescue
      _ -> :error
    end
  end

  defp api_key() do
    "c79749ff9bcc1db0ab4ce6f348a7d902"
  end
end
