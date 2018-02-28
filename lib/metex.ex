defmodule Metex do
  @moduledoc """
  Documentation for Metex.
  """

  alias Metex.Aggregator
  alias Metex.Worker
  alias Metex.WorkerAnagram

  @doc """
  Take a list of city names. Return a map of temps and forecasts.
  ## Examples

      iex> Metex.get_temp_and_forecast
      %{
        "miami" => %{forecast: 20.2, temperature: 23.3},
        "moscow" => %{forecast: -7.1, temperature: -3.8}
      }

  """
  def get_temp_and_forecast(cities) do
    num_remaining = Enum.count(cities) * 2
    coordinator_pid = spawn(Aggregator, :loop, [%{}, num_remaining])

    cities
    |> Enum.map(fn city ->

      temp_pid = spawn(Worker, :loop_temperature, [])
      forecast_pid = spawn(Worker, :loop_forecast, [])

      send(temp_pid, {coordinator_pid, city})
      send(forecast_pid, {coordinator_pid, city})
    end)
  end

  def get_anagrams(filePath) do

    if File.exists?(filePath) do
      stream = File.stream!(filePath, [:read, :utf8])
      data = Enum.reduce stream, %{}, fn(line, m) ->
        anagram = WorkerAnagram.get(line)
        m |> Map.put(line, anagram)
      end
    end

    data

  end

end
