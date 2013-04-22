config = require("./config")
restify = require("restify")
mongoose = require("mongoose")
http = require("http")

db = mongoose.connect(config.creds.mongoose_auth)
Schema = mongoose.Schema
ObjectId = mongoose.Schema.Types.ObjectId;

serverName = "Rotate! - Server"
serverVersion = "0.0.1"

server = restify.createServer(
	name: serverName
	version: serverVersion
)

server.use restify.bodyParser()

# magic code here!
# adding our custom headers, BUT
# restify is still buggy about custom headers
# so we need to monkey patch it

monkey_response = require("http").ServerResponse
original_writeHead = monkey_response::writeHead
monkey_response::writeHead = ->
  default_headers = @getHeader("Access-Control-Allow-Headers")
  @setHeader "Access-Control-Allow-Headers", default_headers + ", pragma, cache-control" if default_headers
  original_writeHead.apply this, arguments

#exception handler
process.on "uncaughtException", (err) ->
  console.log "*** managed exception starts: ***"
  console.log err
  console.log "*** managed exception ends ***"

# database definitions
Devices = new Schema(
  name: String
  uuid: String
  userid: ObjectId
)

Spins = new Schema(
  points: Number
  when: Number
  displayname: String
)

Users = new Schema(
  displayname: String
  lastLogin: Number
  lastGamePlayed: Number
  devices: [Devices]
  spins: [Spins]
)

# models definitions
mongoose.model "User", Users
User = mongoose.model("User")

mongoose.model "Device", Devices
Device = mongoose.model("Device")

mongoose.model "Spin", Spins
Spin = mongoose.model("Spin")

# default errors and responses
errorMsgSecurityToken = (code: 401, message: ':-(', properMessage: 'this is a protected resource, you need to supply the right security token to access it')
errorMsgUserNotFound = (code: 402, message: ':-(', properMessage: 'I could not find the user you requested')

# server methods implementation

getIndex = (req, res, next) ->
  res.send "index, you should not access this page in this way. Go away >:("

genericLogin = (req, res, next) ->
  if req.params.securityToken
    User.findById(req.params.securityToken, (err, user) ->
      if user
        res.send user
      else
        # if the user wasn't found, sign him up
        deviceLogin req, res  
    )
  else
    deviceLogin req, res

deviceLogin = (req, res) ->
  Device.findOne(uuid: req.params.uuid, (err, device) ->
    if not device
      deviceSignup req, res
    else
      User.findById(device.userid, (err, user) ->
        res.send user
      )
  )

deviceSignup = (req, res) ->
  # complete new signup
  user = new User()
  newUserDefault(user, req)

  user.save((err, savedUser) ->

    newDevice = new Device()
    newDevice.name = req.params.deviceName
    newDevice.uuid = req.params.uuid
    newDevice.userid = savedUser._id
    newDevice.save()

    savedUser.devices.push(newDevice)
    savedUser.save()

    res.send savedUser

  )

newUserDefault = (user, req) ->
  user.displayname = req.params.displayname or "A random gamer"
  user.lastLogin = (new Date()).getTime()
  user.lastGamePlayed = (new Date()).getTime()
  user.devices = []
  user.spins = []

getSpins = (req, res, next) ->
  Spin.find().limit(5).sort('-points').execFind((err1, bestSpins) ->
    Spin.find().limit(5).sort('points').execFind((err2, worstSpins) ->
      res.send {best: bestSpins, worst: worstSpins}
    )
  )


addSpin = (req, res, next) ->
  if req.params.securityToken
    User.findById(req.params.securityToken, (err, user) ->

      if not user
        res.send errorMsgUserNotFound
        return;

      currentSpin = new Spin()
      currentSpin.points = req.params.points
      currentSpin.when = (new Date()).getTime()
      currentSpin.displayname = req.params.displayname

      currentSpin.save()

      Spin.find().limit(5).sort('-points').execFind((err1, bestSpins)->
        Spin.find().limit(5).sort('points').execFind((err2, worstSpins)->
          res.send {best: bestSpins, worst: worstSpins, you: currentSpin, enumPosition: 1}
        )
      )

    )
  else
    res.send errorMsgSecurityToken

server.get "/", getIndex
server.get "/spins", getSpins

server.post "/login", genericLogin
server.post "/spins/add", addSpin

server.listen 9999, ->
  console.log "%s listening at %s", server.name, server.url


  