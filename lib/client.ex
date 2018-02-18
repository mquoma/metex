defmodule Metex.Client do
  import Metex.Worker
  alias Metex.Worker

  def get_temps() do
    cities
    |> Enum.map(fn c -> c |> Worker.temperature_of() end)
  end

  def temps() do
    cities
    |> Enum.map(fn c ->
      pid = spawn(Worker, :loop_temperature, [])
      send(pid, {self, c})
    end)
  end

  def forecasts() do
    cities
    |> Enum.map(fn c ->
      pid = spawn(Worker, :loop_forecast, [])
      send(pid, {self, c})
    end)
  end

  defp cities() do
    [
      "miami",
      "montreal",
      "london",
      "chicago",
      "moscow",
      "tokyo",
      "san diego",
      "madrid",
      "cleveland",
      "paris",
      "berlin",
      "baghdad"
    ]
  end
end
