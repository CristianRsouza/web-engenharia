defmodule WCore.Telemetry.WriteBehind do
  use GenServer
  alias WCore.Telemetry.Cache
  alias WCore.Repo
  alias WCore.Telemetry.NodeMetrics

  @interval 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:flush, state) do
    Cache.get_all()
    |> Enum.chunk_every(500)
    |> Enum.each(&persist/1)

    schedule()
    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :flush, @interval)
  end

  defp persist(batch) do
    Repo.transaction(fn ->
      Enum.each(batch, fn {node_id, status, count, payload, ts} ->
        Repo.insert!(
          %NodeMetrics{
            node_id: node_id,
            status: status,
            total_events_processed: count,
            last_payload: payload,
            last_seen_at: ts
          },
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: [:node_id]
        )
      end)
    end)
  end
end
