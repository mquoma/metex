defmodule MetexTest do
  use ExUnit.Case
  doctest Metex

  test "spawn the Aggregator" do
    pid = Metex.spawn_aggregator(1)
    assert is_pid(pid)
  end
end
