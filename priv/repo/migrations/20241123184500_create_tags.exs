defmodule BjjLib.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end

    create unique_index(:tags, [:name])
  end
end
