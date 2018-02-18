defmodule Metex do
  @moduledoc """
  Documentation for Metex.
  """

  import Metex.Coordinator
  import Metex.Worker
  alias Metex.Coordinator
  alias Metex.Worker

  @doc """
  Hello world.

  ## Examples

      iex> Metex.hello
      :world

  """
  def hello do
    :world
  end

  def temperature_of(cities) do
    total = Enum.count(cities)
    coordinator_pid = spawn(Coordinator, :loop, [[], total])

    cities
    |> Enum.map(fn c ->
      worker_pid = spawn(Worker, :loop_temperature, [])
      send(worker_pid, {coordinator_pid, c})
    end)
  end
end
