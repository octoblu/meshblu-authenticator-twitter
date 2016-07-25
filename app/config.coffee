passport = require 'passport'
TwitterStrategy = require('passport-twitter').Strategy
{DeviceAuthenticator} = require 'meshblu-authenticator-core'

twitterOauthConfig =
  consumerKey: process.env.TWITTER_CLIENT_ID
  consumerSecret: process.env.TWITTER_CLIENT_SECRET
  callbackURL: process.env.TWITTER_CALLBACK_URL
  passReqToCallback: true

class TwitterConfig
  constructor: ({@meshbluHttp, @meshbluJSON}) ->

  onAuthentication: (request, accessToken, refreshToken, profile, done) =>
    profileId = profile?.id
    fakeSecret = 'twitter-authenticator'
    authenticatorUuid = @meshbluJSON.uuid
    authenticatorName = @meshbluJSON.name
    deviceModel = new DeviceAuthenticator {authenticatorUuid, authenticatorName, @meshbluHttp}
    query = {}
    query[authenticatorUuid + '.id'] = profileId
    device =
      name: profile.name
      type: 'octoblu:user'

    getDeviceToken = (uuid) =>
      @meshbluHttp.generateAndStoreToken uuid, (error, device) =>
        throw error if error?
        device.id = profileId
        done null, device

    deviceCreateCallback = (error, createdDevice) =>
      throw error if error?
      getDeviceToken createdDevice?.uuid

    deviceFindCallback = (error, foundDevice) =>
      throw error if error?
      return getDeviceToken foundDevice.uuid if foundDevice?
      deviceModel.create
        query: query
        data: device
        user_id: profileId
        secret: fakeSecret
      , deviceCreateCallback

    deviceModel.findVerified query: query, password: fakeSecret, deviceFindCallback

  register: =>
    passport.use new TwitterStrategy twitterOauthConfig, @onAuthentication

module.exports = TwitterConfig
