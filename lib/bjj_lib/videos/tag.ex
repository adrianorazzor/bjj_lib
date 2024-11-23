defmodule BjjLib.Videos.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do

    field :name, :string
    field :description, :string

    has_many :video_tags, BjjLib.Videos.VideoTag
    has_many :videos, through: [:video_tags, :video]

    timestamps()

    def changeset(tag, attrs) do
      tag
      |> cast(attrs, [:name, :description])
      |> validate_required([:name, :description])
      |> validate_length(:name, min: 5, max: 100)
      |> validate_length(:description, min: 10, max: 1000)
      |> unique_constraint(:name)
      |> update_change(:name, &String.downcase/1)
    end

  end
end
