defmodule BjjLibWeb.VideosLive.Index do
  use BjjLibWeb, :live_view

  alias BjjLib.Videos

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:videos, Videos.list_videos())
     |> assign(:tags, Videos.list_tags())
     |> assign(:selected_tag, nil)
     |> assign(:search_query, "")}
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

  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    selected_tags = toggle_tag(socket.assigns.selected_tags, tag)
    filtered_videos = filter_videos_by_tag(Videos.list_videos(), selected_tags)
    {:noreply, assign(socket, videos: filtered_videos, selected_tags: selected_tags)}
  end

  defp toggle_tag(selected_tags, tag) do
    if Enum.member?(selected_tags, tag) do
      Enum.reject(selected_tags, &(&1 == tag))
    else
      selected_tags ++ [tag]
    end
  end

  defp filter_videos_by_tag(videos, []), do: videos

  defp filter_videos_by_tag(videos, tags) do
    Enum.filter(videos, fn video ->
      Enum.any?(video.tags, &Enum.member?(tags, &1))
    end)
  end
end
