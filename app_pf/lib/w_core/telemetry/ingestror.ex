defmodule WCore.Telemetry.Ingestor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def ingest(node_id, payload) do
    GenServer.cast(__MODULE__, {:heartbeat, node_id, payload})
  end

  def init(state) do
    WCore.Telemetry.Cache.init()
    {:ok, state}
  end

  def handle_cast({:heartbeat, node_id, payload}, state) do
    WCore.Telemetry.Cache.upsert(node_id, payload)

    Phoenix.PubSub.broadcast(
      WCore.PubSub,
      "telemetry",
      {:update, node_id}
    )

    {:noreply, state}
  end
end
