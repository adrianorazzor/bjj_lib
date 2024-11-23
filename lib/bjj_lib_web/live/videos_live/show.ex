defmodule BjjLibWeb.VideosLive.Show do
  use BjjLibWeb, :live_view

  alias BjjLib.Videos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Video Details")
     |> assign(socket, video: Videos.get_video!(id))}
  end
end
