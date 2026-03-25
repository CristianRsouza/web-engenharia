defmodule AppPf.Repo do
  use Ecto.Repo,
    otp_app: :app_pf,
    adapter: Ecto.Adapters.SQLite3
end
