defmodule BjjLib.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :title, :string, null: false
      add :description, :text
      add :youtube_url, :string, null: false

      timestamps()
    end

    create index(:videos, [:youtube_url])
  end
end
