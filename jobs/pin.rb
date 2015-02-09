include Restful
include Weather
include Wikipin

LOCATION = "41.23,2.09"

def suggestions_by_ip
  if ip == "127.0.0.1"
    request_pins("41.23","2.09")
  else
    block = Walk.request_block(ip).doc["ip_block"]
    if block
      longitude = block["point"].scan(/\(([^\)]+)\)/).last.first.split(" ")[0]
      latitude = block["point"].scan(/\(([^\)]+)\)/).last.first.split(" ")[1]
      request_pins("#{longitude},#{latitude}")
    end
  end
end

SCHEDULER.every '1m', :first_in => 0 do |job|
  location = LOCATION.split(',')
  if location
    @pins = request_pins(LOCATION)
  else
    @pins = suggestions_by_ip
  end

  if @pins
    send_event('pins', @pins)

    end
  end
