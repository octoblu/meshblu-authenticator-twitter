passport = require 'passport'
TwitterStrategy = require('passport-twitter').Strategy
{DeviceAuthenticator} = require 'meshblu-authenticator-core'
debug = require('debug')('meshblu-twitter-authenticator:config')

twitterOauthConfig =
  consumerKey: process.env.TWITTER_CLIENT_ID
  consumerSecret: process.env.TWITTER_CLIENT_SECRET
  callbackURL: process.env.TWITTER_CALLBACK_URL
  passReqToCallback: true

class TwitterConfig
  constructor: (@meshbludb, @meshbluJSON) ->

  onAuthentication: (request, accessToken, refreshToken, profile, done) =>
    profileId = profile?.id
    fakeSecret = 'twitter-authenticator'
    authenticatorUuid = @meshbluJSON.uuid
    authenticatorName = @meshbluJSON.name
    deviceModel = new DeviceAuthenticator authenticatorUuid, authenticatorName, meshbludb: @meshbludb
    query = {}
    query[authenticatorUuid + '.id'] = profileId
    device =
      name: profile.name
      type: 'octoblu:user'

    getDeviceToken = (uuid) =>
      @meshbludb.generateAndStoreToken uuid, (error, device) =>
        device.id = profileId
        done null, device

    deviceCreateCallback = (error, createdDevice) =>
      return done error if error?
      getDeviceToken createdDevice?.uuid

    deviceFindCallback = (error, foundDevice) =>
      # return done error if error?
      return getDeviceToken foundDevice.uuid if foundDevice?
      deviceModel.create query, device, profileId, fakeSecret, deviceCreateCallback

    deviceModel.findVerified query, fakeSecret, deviceFindCallback

  register: =>
    passport.use new TwitterStrategy twitterOauthConfig, @onAuthentication

module.exports = TwitterConfig
