defmodule BjjLibWeb.TagsLive.Index do
  use BjjLibWeb, :live_view

  alias BjjLib.Videos
  alias BjjLib.Videos.Tag

  @impl true
  def mount(_params, _session, socket) do
    {:ok, Phoenix.LiveView.stream(socket, :tags, Videos.list_tags())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tag")
    |> assign(:tag, Videos.get_tag!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tag")
    |> assign(:tag, %Tag{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Tags")
    |> assign(:tag, nil)
  end
end
