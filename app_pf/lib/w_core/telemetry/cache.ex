defmodule WCore.Telemetry.Cache do
  def init do
    :ets.new(:w_core_telemetry_cache, [
      :named_table,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: true
      ])
  end


def upsert(node_id, payload) do
  now = DateTime.utc_now()

  :ets.uptade_counter(
    :w_core_telemetry_cache,
    node_id,
    {3, 1, now, payload},
    {node_id, 0, now, payload}
  )

  :ets.insert(
    :w_core_telemtry_cache,
    {node_id, 0, now, payload, get_counter(node_id)}
  )
end

 defp get_count(node_id) do
  case :ets.lookup(:w_core_telemetry_cache, node_id) do
    [{_, _, count, _, _}] -> count
    _ -> 0
  end
end
end
