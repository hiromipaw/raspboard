include Restful
include Youtube

SCHEDULER.every '1m', :first_in => 0 do |job|
    videos = request_youtube_videos("Radiohead")
    if videos
      send_event('videos', videos)
    else
      puts "\e[Something went wrong.\e[0m"
    end
end
