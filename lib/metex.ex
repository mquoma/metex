defmodule Metex do
  @moduledoc """
  Documentation for Metex.
  """

  alias Metex.Aggregator
  alias Metex.Worker

  @doc """
  Take an init_remaining value
  Return a pid representing the Aggregator

  """
  def spawn_aggregator(init_remaining) do
     spawn(Aggregator, :loop, [%{}, init_remaining])
  end

  @doc """
  Take a list of city names. Return a map of temps and forecasts.

  """
  def get_temp_and_forecast(cities) do
    coordinator_pid =
      (Enum.count(cities) * 2)
        |> spawn_aggregator()

    cities
    |> Enum.map(fn city ->
      temp_pid = spawn(Worker, :loop_temperature, [])
      forecast_pid = spawn(Worker, :loop_forecast, [])
      send(temp_pid, {coordinator_pid, city})
      send(forecast_pid, {coordinator_pid, city})
    end)
  end
end
