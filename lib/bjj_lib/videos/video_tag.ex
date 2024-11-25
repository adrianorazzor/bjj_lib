defmodule BjjLib.Videos.VideoTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "video_tags" do
    belongs_to :video, BjjLib.Videos.Video
    belongs_to :tag, BjjLib.Videos.Tag

    timestamps()
  end

  def changeset(video_tag, attrs) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    video_tag
    |> cast(attrs, [:video_id, :tag_id])
    |> validate_required([:video_id, :tag_id])
    |> unique_constraint([:video_id, :tag_id])
    |> put_change(:inserted_at, now)
    |> put_change(:updated_at, now)
  end
end
