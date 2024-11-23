defmodule BjjLib.Repo.Migrations.CreateVideoTags do
  use Ecto.Migration

  def change do
    create table(:video_tags) do
      add :video_id, references(:videos, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:video_tags, [:video_id])
    create index(:video_tags, [:tag_id])
    create unique_index(:video_tags, [:video_id, :tag_id])
  end
end
