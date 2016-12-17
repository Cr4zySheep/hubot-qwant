# Description
#   Use the qwant search engine in order to perform a search query
#
# Dependencies
#   "underscore": "1.8.3"
#
# Configuration:
#
# Commands:
#   hubot qwant <query> - Displays results of your <query> using the qwant search engine
#
# Notes:
#
# Author:
#   Loïc M. <mura.loic0@gmail.com>

_ = require('underscore');

module.exports = (robot) ->
  robot.respond /qwant (.*)/i, (msg) ->
    query = msg.match[1]

    robot.http("https://api.qwant.com/api/search/web?count=10&offset=0&q=\"" + query + '"')
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :-( #{err}"
          return

        data = JSON.parse body
        for i in [0..2]
          title = parseText(data.data.result.items[i].title)
          desc = parseText(data.data.result.items[i].desc)
          url = data.data.result.items[i].url
          msg.send "\n#{i+1}: #{title} \n#{desc} \n#{url}\n"

parseText = (text) ->
  text = _.unescape text
  text = text.replace /&#0?39;/g, "'"
  text = text.replace /(<b>)|(<\/b>)/g, ''
  return text
