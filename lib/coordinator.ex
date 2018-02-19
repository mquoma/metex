defmodule Metex.Coordinator do
  def loop(results \\ %{}, num_remaining) do
    receive do
      {:ok, arg, value, city} ->
        new_results =
          results
          |> Map.put_new(city, %{})
          |> Kernel.put_in([city, arg], value)

        if num_remaining == 1 do
          send(self(), :exit)
        end

        loop(new_results, num_remaining - 1)

      :exit ->
        results |> IO.inspect()

      _ ->
        IO.puts("unexpected msg")
        loop(results, num_remaining)
    end
  end
end
