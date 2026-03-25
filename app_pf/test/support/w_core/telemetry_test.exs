defmodule WCore.TelemetryTest do
  use ExUnit.Case

  test "handles 10k events" do
    tasks =
      for i <- 1..10_000 do
        Task.async(fn ->
          WCore.Telemetry.Ingestor.ingest("node_#{rem(i, 50)}", %{v: i})
        end)
      end

    Task.await_many(tasks)

    :timer.sleep(2000)

    data = :ets.tab2list(:w_core_telemetry_cache)

    assert length(data) > 0
  end
end
