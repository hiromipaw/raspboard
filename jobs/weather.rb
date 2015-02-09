include Restful
include Weather
include Wikipin

LOCATION = "41.23,2.09"

def suggestions_by_ip
  if ip == "127.0.0.1"
    get_weather("41.23","2.09")
  else
    block = Walk.request_block(ip).doc["ip_block"]
    if block
      longitude = block["point"].scan(/\(([^\)]+)\)/).last.first.split(" ")[0]
      latitude = block["point"].scan(/\(([^\)]+)\)/).last.first.split(" ")[1]
      make_forecast(latitude, longitude)
    end
  end
end

def make_forecast(latitude, longitude)
  forecast = get_weather(latitude,longitude)
end

SCHEDULER.every '1m', :first_in => 0 do |job|
  location = LOCATION.split(',')
  if location
    @forecast = make_forecast(location[0],location[1])
  else
    @forecast = suggestions_by_ip
  end

  if @forecast
    send_event('weather', {
        name: @forecast[:forecast].doc["name"],
        country: @forecast[:forecast].doc["sys"]["country"],
        coord: @forecast[:forecast].doc["coord"],
        code: @forecast[:forecast].doc["weather"][0]["id"]
      })

  end
end
