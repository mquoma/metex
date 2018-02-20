defmodule Metex do
  @moduledoc """
  Documentation for Metex.
  """

  alias Metex.Coordinator
  alias Metex.Worker

  @doc """
  Get temp and forecast.
  ## Examples

      iex> Metex.get_temp_and_forecast
      %{
        "miami" => %{forecast: 20.2, temperature: 23.3},
        "moscow" => %{forecast: -7.1, temperature: -3.8}
      }

  """
  def get_temp_and_forecast(cities) do
    num_remaining = Enum.count(cities) * 2
    coordinator_pid = spawn(Coordinator, :loop, [%{}, num_remaining])

    cities
    |> Enum.map(fn city ->

      temp_pid = spawn(Worker, :loop_temperature, [])
      forecast_pid = spawn(Worker, :loop_forecast, [])

      send(temp_pid, {coordinator_pid, city})
      send(forecast_pid, {coordinator_pid, city})
    end)
  end
end
