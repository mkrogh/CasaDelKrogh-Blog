window.App = Em.Application.create
  rootElement: "#twitter-feed"

tweets = [
  {text: "@mbogh Hehe always nice to be noted :P On a different note, make your app faster and loose weight by compressing images http:\/\/t.co\/augTUv6D"
  retweet_count: 0
  user:
    id: 255525994
  created_at: "created_at":"Mon Mar 19 11:56:57 +0000 2012"}
  {"retweet_count": 0
  "text": "@TheNix http:\/\/t.co\/WHCyyY2l is a good source on what json is. But why video tutorials?"
  "created_at": "Sun Mar 18 18:16:38 +0000 2012"}
  ]

App.Feed = Em.ArrayController.create
  content: []
  loadTweets: ->
    self = this
    $.get('/twitter/feed/')
      .success (tweets) ->
        tweets = $.parseJSON(tweets) if typeof tweets == "string"
        tweets = tweets.map (tweet) ->
          App.Tweet.create tweet
        self.set("content", tweets)
      .error (msg) ->
        self.set("content", [App.Tweet.create
          text: "Unable to fetch tweets.. :( ("+msg.status+")"])

App.Tweet = Em.Object.extend
  text: ""
  retweet_count: 0
  user: null
  created_at: null

###
window.setTimeout(->
    App.Feed.set "content", tweets.map (tweet) ->
      App.Tweet.create tweet
  , 1000)
###
App.animateFeedState = 1
App.animateFeed = ->
  tweets = $(".tweet-feed li")
  scrollby = _.first(tweets,App.animateFeedState)
  offset = _.reduce(scrollby, (memo,el) -> 
    memo+$(el).outerHeight(true)
  ,0)
  tweets.css("bottom", offset+"px")
  App.animateFeedState++
  App.animateFeedState = 0 if App.animateFeedState >= tweets.length
  setTimeout(App.animateFeed, 5000)

# Handlebar extensions
Handlebars.registerHelper "tweet", (tweet) ->
  tweet

#App-Start up
$(document).ready ->
  App.Feed.loadTweets()
  setTimeout App.animateFeed, 4000
