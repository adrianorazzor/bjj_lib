defmodule BjjLib.Videos.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    many_to_many :videos, BjjLib.Videos.Video,
      join_through: BjjLib.Videos.VideoTag,
      on_replace: :delete

    timestamps()
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    # Adjusted validation
    |> validate_length(:name, min: 2, max: 30)
    |> unique_constraint(:name)
    |> update_change(:name, &String.downcase/1)
  end
end
