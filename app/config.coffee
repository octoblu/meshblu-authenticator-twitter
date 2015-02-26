passport = require 'passport'
TwitterStrategy = require('passport-twitter').Strategy

twitterOauthConfig =
  consumerKey: process.env.TWITTER_CONSUMER_KEY
  consumerSecret: process.env.TWITTER_CONSUMER_SECRET
  callbackURL: 'http://localhost:8007/api/auth/callback'

class TwitterConfig
  onAuthentication: (token, tokenSecret, profile, done) =>
    console.log 'Authenticated', token, tokenSecret, profile
    done null, {id: profile.id, name: profile.name}
  register: =>
    passport.use new TwitterStrategy twitterOauthConfig, @onAuthentication

module.exports = TwitterConfig
