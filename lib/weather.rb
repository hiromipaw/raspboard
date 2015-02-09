require 'net/http'
require 'json'

module Weather
    WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?"

    def get_weather(lat, lon)
      forecast = {
        forecast: send_request("#{WEATHER_URL}lat=#{lat}&lon=#{lon}")
      }
    end

end
