require('mocha')
expect = require('chai').expect
hapi = require('hapi')
request = require('request')

lego = require(__dirname + '/../lego.js')
server = new hapi.Server()

port = 8000


describe('If', ->
  server = new hapi.Server()

  before(()->
    server.connection(
      port: 8000
    )

    lego.attach(server, __dirname + '/templates/')

    server.route(
      method: 'GET'
      path: '/'
      handler: (request, reply) ->
        reply.view('main_if',
          showHeader: false
        )
      config:
        state:
          parse: false
          failAction: 'ignore'
    )
    
    server.route(
      method: 'GET'
      path: '/2'
      handler: (request, reply) ->
        reply.view('main_if',
          showHeader: [true]
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
  
  it('Should not include header', (done)->
    request('http://localhost:8000', (err, response, body)->
      expect(body).to.equal("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          
          
          
            <p>Bar</p>
          
        </body>
      </html>
      """)
      
      done()
    )  
  )
  
  it('Should include header', (done)->
    request('http://localhost:8000/2', (err, response, body)->
      expect(body).to.equal("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          
            
              <h1>Header</h1>\n<!-- foo bar -->
            
          
          
          
        </body>
      </html>
      """)
      
      done()
    )  
  )

)