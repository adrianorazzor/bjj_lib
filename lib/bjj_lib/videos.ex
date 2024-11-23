defmodule BjjLib.Videos do
  import Ecto.Query
  alias BjjLib.Repo
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
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def change_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
  end

  def list_tags do
    Tag
    |> Repo.all()
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
      where: ilike(v.title, ^wildcard_query) or
             ilike(v.description, ^wildcard_query) or
             ilike(t.name, ^wildcard_query),
      preload: [:tags],
      distinct: true
    )
    |> Repo.all()
  end
end
