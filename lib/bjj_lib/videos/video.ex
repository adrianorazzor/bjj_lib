defmodule BjjLib.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  alias BjjLib.Repo
  alias BjjLib.Videos.{Tag, VideoTag}

  schema "videos" do
    field :title, :string
    field :description, :string
    field :youtube_url, :string
    field :tag_list, :string, virtual: true

    many_to_many :tags, Tag,
      join_through: VideoTag,
      on_replace: :delete,
      join_defaults: [
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      ]

    timestamps()
  end

  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :description, :youtube_url, :tag_list])
    |> validate_required([:title, :description, :youtube_url])
    |> validate_youtube_url(:youtube_url)
    |> maybe_put_tags(attrs)
  end

  defp maybe_put_tags(changeset, _attrs) do
    if tag_list = get_change(changeset, :tag_list) do
      tags =
        tag_list
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(&find_or_create_tag/1)

      put_assoc(changeset, :tags, tags)
    else
      changeset
    end
  end

  defp validate_youtube_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case extract_youtube_id(url) do
        {:ok, _} -> []
        :error -> [{field, "Invalid youtube URL"}]
      end
    end)
  end

  defp extract_youtube_id(url) when is_binary(url) do
    patterns = [
      ~r/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/,
      ~r/^([^&\n?#]+)$/
    ]

    Enum.find_value(patterns, :error, fn pattern ->
      case Regex.run(pattern, url) do
        [_, id] -> {:ok, id}
        _ -> nil
      end
    end)
  end

  defp extract_youtube_id(_), do: :error

  defp find_or_create_tag(name) do
    name = String.downcase(name)

    case Repo.get_by(Tag, name: name) do
      nil ->
        {:ok, tag} =
          %Tag{}
          |> Tag.changeset(%{name: name})
          |> Repo.insert()

        tag

      tag ->
        tag
    end
  end
end
