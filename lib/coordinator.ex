defmodule Metex.Coordinator do
  def loop(results \\ [], total_count) do
    receive do
      {:ok, data} ->
        new_results = [data | results]

        if total_count == Enum.count(new_results) do
          send(self, :exit)
        end

        loop(new_results, total_count)

      :exit ->
        results |> Enum.sort() |> Enum.join(", ") |> IO.inspect()

      _ ->
        IO.puts("unexpected msg")
        loop(results, total_count)
    end
  end
end
