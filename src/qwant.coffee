# Description
#   Use the qwant unofficialy API in order to perform a search query
#
# Dependencies
#   "he": "^1.1.0"
#
# Commands:
#   hubot qwant <query> - Displays web results of your <query> using the qwant API
#   hubot qnews <query> - Displays news results of your <query> using the qwant API
#   hubot qsocial <query> - Displays social results of your <query> using the qwant API
#   hubot qimg <query> - Displays images results of your <query> using the qwant API
#   hubot qvideos <query> - Displays videos results of your <query> using the qwant API
#
# Author:
#   Loïc M. <mura.loic0@gmail.com>

_ = require('underscore');
he = require('he');

module.exports = (robot) ->
  robot.respond /qwant (.*)/i, (msg) ->
    search robot, msg, msg.match[1], 'web', 3, (i, item) ->
      title = parseText(item.title)
      desc = parseText(item.desc)
      url = item.url
      msg.send "\n#{i}: #{title} \n#{desc} \n#{url}\n"

  robot.respond /qnews (.*)/i, (msg) ->
    search robot, msg, msg.match[1], 'news', 3, (i, item) ->
      title = parseText(item.title)
      desc = parseText(item.desc)
      url = item.url
      msg.send "\n#{i}: #{title} \n#{desc} \n#{url}\n"

  robot.respond /qimg (.*)/i, (msg) ->
    search robot, msg, msg.match[1], 'images', 5, (i, item) ->
      title = parseText item.title
      size = item.width + "x" + item.height
      desc = parseText(item.desc)
      url = item.url
      msg.send "\n#{i}: #{size} - #{title}\n #{url}\n"

  robot.respond /qsocial (.*)/i, (msg) ->
    search robot, msg, msg.match[1], 'social', 5, (i, item) ->
      user = parseText item.card
      desc = parseText item.desc
      url = item.url
      msg.send "\n#{i}: @#{user}\n #{desc}\n #{url}\n"

  robot.respond /qvideos (.*)/i, (msg) ->
    search robot, msg, msg.match[1], 'videos', 3, (i, item) ->
      title = parseText item.title
      size = item.width + "x" + item.height
      desc = parseText(item.desc)
      url = item.url
      msg.send "\n#{i}: #{title}\n #{desc}\n #{url}\n"

parseText = (text) ->
  text = he.decode text
  text = text.replace /(<b>)|(<\/b>)/g, ''
  return text

search = (robot, msg, query, category, display_count, callback) ->
  if !(category in ['web', 'images', 'news', 'social', 'videos'])
    return

  robot.http("https://api.qwant.com/api/search/" + category + "?count=10&offset=0&q=\"" + query + '"')
    .header('Accept', 'application/json')
    .get() (err, res, body) ->
      if err
        msg.send "Encountered an error :-( #{err}"
        return

      data = (JSON.parse body).data
      if data.result.items.length != 0
        if display_count <= 0
          display_count = 1

        callback i+1, data.result.items[i] for i in [0..display_count-1]
      else msg.send 'Nothing matches your query.'
