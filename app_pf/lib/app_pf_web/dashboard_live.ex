defmodule AppPfWeb.DashboardLive do
  use AppPfWeb, :live_view

  def mount(_, _, socket) do
    Phoenix.PubSub.subscribe(AppPf.PubSub, "telemetry")

    nodes =
      if :ets.whereis(:w_core_telemetry_cache) != :undefined do
        :ets.tab2list(:w_core_telemetry_cache)
      else
        []
      end

    {:ok, assign(socket, nodes: nodes)}
  end

  def handle_info({:update, _node_id}, socket) do
    nodes = :ets.tab2list(:w_core_telemetry_cache)
    {:noreply, assign(socket, nodes: nodes)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Telemetry</h1>
      <ul>
        <%= for {id, status, count, _, _} <- @nodes do %>
          <li>
            <%= id %> - <%= status %> - <%= count %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
