defmodule BjjLibWeb.Helpers.VideoHelpers do
  @doc """
  Extracts YouTube video ID from various YouTube URL formats
  """
  def extract_youtube_id(url) when is_binary(url) do
    patterns = [
      ~r/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/,
      ~r/^([^&\n?#]+)$/
    ]

    case Enum.find_value(patterns, fn pattern ->
           case Regex.run(pattern, url) do
             [_, id] -> id
             _ -> nil
           end
         end) do
      nil -> ""
      id -> id
    end
  end

  def extract_youtube_id(_), do: ""
end
