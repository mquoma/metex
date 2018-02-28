defmodule Metex.Aggregator do
  def loop(results \\ %{}, num_remaining) do
    receive do
      {:ok, prop, value, city} ->

        new_results =
          results
          |> Map.put_new(city, %{})   #Add this city if we haven't seen it yet
          |> Kernel.put_in([city, prop], value)  #Put this prop and value in

        if num_remaining == 1 do
          send(self(), :exit)
        end

        loop(new_results, num_remaining - 1)

      :exit ->
        IO.puts "exiting successfully: "
        results |> IO.inspect()

      _ ->
        IO.puts("unexpected msg")
        loop(results, num_remaining)
    end
  end

  def loop_anagrams(results \\ %{}, num_remaining) do
    receive do
      {:ok, prop, value} ->

        new_results =
          results
          |> Map.put(prop, value)

        if num_remaining == 1 do
          send(self(), :exit)
        end

        loop_anagrams(new_results, num_remaining - 1)

      :exit ->
        IO.puts "exiting successfully: "
        results |> IO.inspect()

      err ->
        IO.puts("unexpected msg")
        IO.inspect err
        loop_anagrams(results, num_remaining)
    end
  end
end
