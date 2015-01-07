require('mocha')
expect = require('chai').expect
hapi = require('hapi')
request = require('request')
config = require(__dirname + '/config.coffee')

lego = require(__dirname + '/../lego.js')
server = new hapi.Server()



describe('Define', ->
  server = new hapi.Server()

  before(()->
    server.connection(
      port: config.port
    )

    lego.attach(server, __dirname + '/templates/')

    server.route(
      method: 'GET'
      path: '/'
      handler: (request, reply) ->
        reply.view('main_define',
          arr: [1,2,3]
        )
      config:
        state:
          parse: false
          failAction: 'ignore'
    )
    
    server.start()
  )
  
  after(()->
    server.stop()
  )
  
  it('Should iterate through defined value', (done)->
    request('http://localhost:'+config.port, (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <table class="1"></table>
          <table class="2"></table>
          <table class="3"></table>
        </body>
      </html>
      """))
      
      done()
    )  
  )

)