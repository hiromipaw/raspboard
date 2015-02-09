require "net/http"
require "json"
require "google/api_client"
require "trollop"

module Youtube

  DEVELOPER_KEY = "AIzaSyDr5BkOtiSFzU-t22DXLWsLon34DXDhSFo"
  YOUTUBE_API_SERVICE_NAME = "youtube"
  YOUTUBE_API_VERSION = "v3"

  def get_service
    client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => 'youtube-api-module',
    :application_version => '1.0.0'
    )
    youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

    return client, youtube
  end

  def wrap_search_results(videos, channels, playlists)
    search_results = {
      items: videos.take(3)
    }
  end

  def wrap_json(search_result)
    result = {
        label: search_result.snippet.title,
        value: make_video_url(search_result),
        title: search_result.snippet.title,
        description: search_result.snippet.description,
        url: make_video_url(search_result)
    }
  end

  def make_video_url(search_result)
    case search_result.id.kind
    when 'youtube#video'
      "https://www.youtube.com/watch?v=#{search_result.id.videoId}"
    when 'youtube#channel'
      "https://www.youtube.com/channel/#{search_result.id.channelId}"
    when 'youtube#playlist'
      "https://www.youtube.com/playlist?list=#{search_result.id.playlistId}"
    end
  end

  def request_youtube_videos(query)
    opts = Trollop::options do
      opt :q, 'Search term', :type => String, :default => query
      opt :max_results, 'Max results', :type => :int, :default => 25
    end

    client, youtube = get_service
    begin
      # Call the search.list method to retrieve results matching the specified
      # query term.
      search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => {
        :part => 'snippet',
        :q => opts[:q],
        :maxResults => opts[:max_results]
      }
      )

      videos = []
      channels = []
      playlists = []

      # Add each result to the appropriate list, and then display the lists of
      # matching videos, channels, and playlists.
      search_response.data.items.each do |search_result|
        case search_result.id.kind
        when 'youtube#video'
          videos << wrap_json(search_result)
        when 'youtube#channel'
          channels << wrap_json(search_result)
        when 'youtube#playlist'
          playlists << wrap_json(search_result)
        end
      end

      wrap_search_results(videos, channels, playlists)

    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
    end

  end
end
