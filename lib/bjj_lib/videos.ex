defmodule BjjLib.Videos do
  import Ecto.Query
  alias BjjLib.Repo
  alias Ecto.Multi
  alias BjjLib.Videos.{Video, Tag}

  def list_videos do
    Video
    |> preload(:tags)
    |> Repo.all()
  end

  def get_video!(id) do
    Video
    |> preload(:tags)
    |> Repo.get!(id)
  end

  def create_video(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:video, Video.changeset(%Video{}, attrs))
    |> Multi.run(:video_with_tags, fn repo, %{video: video} ->
      video = repo.preload(video, :tags)
      {:ok, video}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{video_with_tags: video}} -> {:ok, video}
      {:error, _operation, changeset, _changes} -> {:error, changeset}
    end
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  def list_tags do
    Repo.all(Tag)
  end

  def get_tag!(id) do
    Tag
    |> Repo.get!(id)
  end

  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create_tag(name) do
    name = String.downcase(name)

    case Repo.get_by(Tag, name: name) do
      nil -> create_tag(%{name: name})
      tag -> {:ok, tag}
    end
  end

  def search_videos(query) do
    wildcard_query = "%#{query}%"

    from(v in Video,
      join: t in assoc(v, :tags),
      where:
        ilike(v.title, ^wildcard_query) or
          ilike(v.description, ^wildcard_query) or
          ilike(t.name, ^wildcard_query),
      preload: [:tags],
      distinct: true
    )
    |> Repo.all()
  end

  def handle_tags(changeset, attrs) do
    if tag_list = attrs["tag_list"] || attrs[:tag_list] do
      tags =
        tag_list
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(&find_or_create_tag/1)
        |> Enum.map(fn {:ok, tag} -> tag end)

      Ecto.Changeset.put_assoc(changeset, :tags, tags)
    end
  end
end
