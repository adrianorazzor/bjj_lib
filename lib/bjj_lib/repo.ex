defmodule BjjLib.Repo do
  use Ecto.Repo,
    otp_app: :bjj_lib,
    adapter: Ecto.Adapters.Postgres
end
