express = require 'express'
http = require 'http'
path = require 'path'
stylus = require 'stylus'
fs = require 'fs'
coffee = require 'coffee-script'
cluster = require 'cluster'
numCpus = require('os').cpus().length

if cluster.isMaster
  for i in [1..numCpus]
    cluster.fork()
    cluster.on 'exit', (worler, code, signal) ->
      exitCode = worker.process.exitCode
      console.log('worker ' + worker.process.pid + ' died ('+exitCode+'). restarting...')
      cluster.fork()
else
  app = express()
  app.configure ->
    app.set('port', process.env.PORT || 3000)
    app.set('views', "#{__dirname}/app/views")
    app.set('view engine', 'ejs')
    app.use(express.favicon())
    app.use(express.logger('dev'))
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use stylus.middleware
      src: "#{__dirname}/app/assets"
      dest: __dirname + '/public'
      compress: true
    app.use(express.static("#{__dirname}/public"))
    app.use(express.static("#{__dirname}/app/assets/javascripts"))
    app.use(app.router)
  
  app.configure 'development', ->
    app.use(express.errorHandler())
    app.get /.js$/, (req, res) ->
      coffeePath = 'app/assets/javascripts'
      reqJs = req.originalUrl.substring(1, req.originalUrl.length - 3)
      res.header 'Content-Type', 'application/x-javascript'
      cs = fs.readFileSync "#{__dirname}/#{coffeePath}/#{reqJs}.coffee", "ascii"
      js = coffee.compile cs
      res.send js
    app.use(express.static("#{__dirname}/app/assets/javascripts"))
  
  require("#{__dirname}/app/router")(app)
  
  http.createServer(app).listen app.get('port'), () ->
    console.log('Express server listening on port ' + app.get('port') + ' worker' + cluster.worker.id)
  
module.exports.app = app
