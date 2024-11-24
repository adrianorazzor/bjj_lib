defmodule BjjLibWeb.VideoComponents do
  use Phoenix.Component

  alias BjjLibWeb.Helpers.VideoHelpers


  def video_card(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden">
      <div class="aspect-w-16 aspect-h-9">
        <iframe
            src={"https://www.youtube.com/embed/#{VideoHelpers.extract_youtube_id(@video.youtube_url)}"}
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen
          class="w-full h-full"
        >
        </iframe>
      </div>
      <div class="p-5">
        <h3 class="text-lg font-semibold text-gray-900 line-clamp-1 mb-2">
          <%= @video.title %>
        </h3>
        <p class="text-sm text-gray-600 line-clamp-2 mb-4">
          <%= @video.description %>
        </p>
        <div class="flex flex-wrap gap-2">
          <%= for tag <- @video.tags do %>
            <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-blue-50 text-blue-700 hover:bg-blue-100 transition-colors">
              <%= tag.name %>
            </span>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def search_bar(assigns) do
    ~H"""
    <div class="relative">
      <form phx-submit="search" class="relative">
        <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
          <svg class="w-4 h-4 text-gray-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
        <input
          type="text"
          name="query"
          value={@query}
          placeholder="Search videos..."
          class="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          phx-debounce="300"
        />
      </form>
    </div>
    """
  end

  def tag_sidebar(assigns) do
    ~H"""
    <div class="w-64 flex-shrink-0 space-y-4">
      <div class="bg-white rounded-xl shadow-sm p-5">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Filter by Tags</h3>
        <div class="space-y-2">
          <%= if Enum.empty?(@tags) do %>
            <p class="text-sm text-gray-500">No tags available</p>
          <% else %>
            <%= for tag <- @tags do %>
              <button
                phx-click="filter_tag"
                phx-value-tag={tag.name}
                class={[
                  "w-full text-left px-3 py-2 rounded-lg text-sm transition-all duration-200",
                  if(tag.name in @selected_tags,
                    do: "bg-blue-100 text-blue-800 hover:bg-blue-200",
                    else: "hover:bg-gray-50"
                  )
                ]}
              >
                <div class="flex items-center justify-between">
                  <span><%= tag.name %></span>
                  <%= if tag.name in @selected_tags do %>
                    <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                    </svg>
                  <% end %>
                </div>
              </button>
            <% end %>
          <% end %>
        </div>
      </div>
      <%= if length(@selected_tags) > 0 do %>
        <button
          phx-click="clear_filters"
          class="w-full text-center text-sm text-red-600 hover:text-red-800 font-medium"
        >
          Clear filters
        </button>
      <% end %>
    </div>
    """
  end
end
