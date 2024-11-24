defmodule BjjLibWeb.VideosLive.Index do
  use BjjLibWeb, :live_view

  alias BjjLib.Videos

  @impl true
  def mount(_params, _session, socket) do
    videos = Videos.list_videos()

    {:ok,
     socket
     |> assign(:videos, videos)  # Add this line to assign videos
     |> assign(:tags, Videos.list_tags())
     |> assign(:selected_tags, [])
     |> assign(:search_query, "")
     |> assign(:page_title, "BJJ Video Library")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Video")
    |> assign(:video, Videos.get_video!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Video")
    |> assign(:video, %Videos.Video{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "BJJ Library")
    |> assign(:video, nil)
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    video = Videos.search_videos(query)
    {:noreply, assign(socket, videos: video, search_query: query)}
  end

  @impl true
  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    selected_tags = toggle_tag(socket.assigns.selected_tags, tag)
    filtered_videos = filter_videos_by_tags(Videos.list_videos(), selected_tags)

    {:noreply,
     socket
     |> assign(:selected_tags, selected_tags)
     |> assign(:videos, filtered_videos)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    video = Videos.get_video!(id)
    {:ok, _} = Videos.delete_video(video)

    {:noreply, stream_delete(socket, :videos, video)}
  end

  @impl true
  def handle_event("clear_filters", _, socket) do
    {:noreply,
     socket
     |> assign(:selected_tags, [])
     |> assign(:videos, Videos.list_videos())}
  end

  defp toggle_tag(selected_tags, tag) do
    if tag in selected_tags do
      List.delete(selected_tags, tag)
    else
      [tag | selected_tags]
    end
  end

  defp filter_videos_by_tags(videos, []), do: videos

  defp filter_videos_by_tags(videos, selected_tags) do
    Enum.filter(videos, fn video ->
      video_tags = Enum.map(video.tags, & &1.name)
      Enum.all?(selected_tags, &(&1 in video_tags))
    end)
  end

  @impl true
  def handle_info({BjjLibWeb.VideosLive.FormComponent, {:saved, video}}, socket) do
    # Update the videos list when a new video is saved
    updated_videos = [video | socket.assigns.videos]
    {:noreply, assign(socket, :videos, updated_videos)}
  end
end
