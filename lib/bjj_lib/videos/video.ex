defmodule BjjLib.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :title, :string
    field :description, :string
    field :youtube_url, :string
    field :tag_list, :string, virtual: true

    has_many :video_tags, BjjLib.Videos.VideoTag
    has_many :tags, through: [:video_tags, :tag]

    timestamps()
  end

  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :description, :youtube_url, :tag_list])
    |> validate_required([:title, :description, :youtube_url])
    |> validate_length(:title, min: 5, max: 100)
    |> validate_length(:description, min: 10, max: 1000)
    |> validate_youtube_url(:youtube_url)
    |> handle_tags(attrs)
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

  defp handle_tags(changeset, _attrs) do
    case get_change(changeset, :tag_list) do
      nil ->
        changeset

      tag_list ->
        tags =
          tag_list
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.reject(&(&1 == ""))
          |> Enum.map(&%{name: &1})

        # associate tags with video
        put_assoc(changeset, :tags, tags)
    end
  end
end
