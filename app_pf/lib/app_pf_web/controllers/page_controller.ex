defmodule AppPfWeb.PageController do
  use AppPfWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
