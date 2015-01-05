require('mocha')
expect = require('chai').expect
hapi = require('hapi')
request = require('request')
config = require(__dirname + '/config.coffee')

lego = require(__dirname + '/../lego.js')
server = new hapi.Server()

describe('Require', ->
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
        reply.view('main')
      config:
        state:
          parse: false
          failAction: 'ignore'
    )
    
    server.route(
      method: 'GET'
      path: '/2'
      handler: (request, reply) ->
        reply.view('main_2')
      config:
        state:
          parse: false
          failAction: 'ignore'
    )
    
    server.route(
      method: 'GET'
      path: '/3'
      handler: (request, reply) ->
        reply.view('sub/main_3',
          templatesRoot: './'
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
  
  it('Should require html documents', (done)->
    request('http://localhost:'+config.port, (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <h1>Header</h1>
          <!-- foo bar -->
            <p>Foo</p>
            <span></span>
            <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """))
      
      done()
    )  
  )
  
  it('Should require js sync documents', (done)->
    request('http://localhost:'+config.port+'/2', (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """))
      
      done()
    )
  )
  
  it('Should require js async documents', (done)->
    request('http://localhost:'+config.port+'/3', (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """))
      
      done()
    )
  )
)