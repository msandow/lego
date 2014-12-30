hapi = require('hapi')
server = new hapi.Server()
lego = require(__dirname + '/lego.coffee')

server.connection(
  port: 8000
)

server.views(
  engines: 
    html: lego
  path: __dirname + '/../templates'
  compileMode: 'async'
)

server.route(
  method: 'GET'
  path: '/'
  handler: (request, reply) ->
    reply.view('main')
)

module.exports = () ->
  server.start()