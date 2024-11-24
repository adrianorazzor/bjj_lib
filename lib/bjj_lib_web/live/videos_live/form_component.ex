defmodule BjjLibWeb.VideosLive.FormComponent do
  use BjjLibWeb, :live_component


  alias BjjLib.Videos

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="video-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:youtube_url]} type="text" label="YouTube URL" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input
          field={@form[:tag_list]}
          type="text"
          label="Tags"
          placeholder="Enter tags separated by commas"
          phx-debounce="blur"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Video</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{video: video} = assigns, socket) do
    changeset = Videos.change_video(video, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def handle_event("validate", %{"video" => video_params}, socket) do
    # Remove tag_list from validation params
    validation_params = Map.delete(video_params, "tag_list")

    changeset =
      socket.assigns.video
      |> Videos.change_video(validation_params)
      |> Map.put(:action, :validate)

    # Add back tag_list to form data without validation
    changeset = Ecto.Changeset.put_change(changeset, :tag_list, video_params["tag_list"])

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    save_video(socket, socket.assigns.action, video_params)
  end

  defp save_video(socket, :edit, video_params) do
    case Videos.update_video(socket.assign.video, video_params) do
      {:ok, video} ->
        notify_parent({:saved, video})

        {:noreply,
         socket
         |> put_flash(:info, "Video updated successfully")
         |> push_patch(to: socket.assign.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_video(socket, :new, video_params) do
    case Videos.create_video(video_params) do
      {:ok, video} ->
        notify_parent({:saved, video})

        {:noreply,
         socket
         |> put_flash(:info, "Video created successfully")
         |> push_navigate(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
