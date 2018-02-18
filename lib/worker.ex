defmodule Metex.Worker do
  # def loop do
  #   receive do
  #     {sender_pid, location} ->
  #       send(sender_pid, {:ok, temperature_of(location)})
  #
  #     _ ->
  #       IO.puts("cannot process this msg")
  #   end
  #
  #   loop
  # end

  def loop_forecast() do
    loop_func(&forecast_of/1)
  end

  def loop_temperature() do
    loop_func(&temperature_of/1)
  end

  def loop_func(arg) do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, arg.(location)})

      _ ->
        IO.puts("cannot process this msg")
    end

    loop_func(arg)
  end

  def temperature_of(location) do
    location
    |> url_for("temperature")
    |> HTTPoison.get()
    |> parse_response("temperature")
    |> case do
      {:ok, temperature} ->
        "#{location} - #{temperature} C"

      :error ->
        "#{location} - error"
    end
  end

  def forecast_of(location) do
    location
    |> url_for("forecast")
    |> HTTPoison.get()
    |> parse_response("forecast")
    |> case do
      {:ok, forecast} ->
        "#{location} - #{forecast}"

      :error ->
        "#{location} - error"
    end
  end

  defp url_for(location, arg) do
    location = URI.encode(location)

    case arg do
      "temperature" ->
        "api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key}"

      "forecast" ->
        "api.openweathermap.org/data/2.5/forecast?q=#{location}&mode=json&appid=#{api_key}"
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}, arg) do
    results =
      body
      |> JSON.decode!()
      |> IO.inspect()

    case arg do
      "temperature" ->
        results |> compute_temperature()

      "forecast" ->
        results |> compute_forecast()
    end
  end

  defp parse_response(_, arg) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temperature =
        (json["main"]["temp"] - 273.15)
        |> Float.round(1)

      {:ok, temperature}
    rescue
      _ -> :error
    end
  end

  defp compute_forecast(json) do
    try do
      forecast =
        json["list"]
        |> List.first()

      {:ok,
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
