hapi = require('hapi')
server = new hapi.Server()
lego = require(__dirname + '/lego.coffee')

server.connection(
  port: 8000
)

lego.attach(server, __dirname + '/../templates')

server.route(
  method: 'GET'
  path: '/'
  handler: (request, reply) ->
    reply.view('main')
)

module.exports = () ->
  server.start()