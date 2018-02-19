defmodule Metex.Worker do
  import Tuple

  def loop_forecast() do
    loop_func(&forecast_of/1)
  end

  def loop_temperature() do
    loop_func(&temperature_of/1)
  end

  def temperature_of(location) do
    location
    |> url_for(:temperature)
    |> HTTPoison.get()
    |> parse_response(:temperature)
    |> append(location)
  end

  def forecast_of(location) do
    location
    |> url_for(:forecast)
    |> HTTPoison.get()
    |> parse_response(:forecast)
    |> append(location)
  end

  defp loop_func(arg) do
    receive do
      {sender_pid, location} ->
        send(sender_pid, arg.(location))

      _ ->
        IO.puts("cannot process this msg")
    end

    loop_func(arg)
  end

  defp url_for(location, arg) do
    location = URI.encode(location)

    case arg do
      :temperature ->
        "api.openweathermap.org/data/2.5/weather?q=#{location}"
        |> append_api_key()

      :forecast ->
        "api.openweathermap.org/data/2.5/forecast?q=#{location}&mode=json"
        |> append_api_key()
    end
  end

  defp append_api_key(url) do
    "#{url}&appid=#{api_key()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}, arg) do
    results =
      body
      |> JSON.decode!()

    case arg do
      :temperature ->
        results |> compute_temperature()

      :forecast ->
        results |> compute_forecast()
    end
  end

  defp parse_response(_resp, _arg) do
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
