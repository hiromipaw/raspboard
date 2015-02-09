class Dashing.Weather extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data
      # reset classes
      $('i.climacon').attr 'class', "climacon wi wi-night-#{data.code}"
