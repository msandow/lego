require('mocha')
expect = require('chai').expect
hapi = require('hapi')
request = require('request')

lego = require(__dirname + '/../lego.js')
server = new hapi.Server()

port = 8000


describe('Insert', ->
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
        reply.view('main',
          foobar: '<!-- lego::insert next -->'
          next: '<i class="<!-- lego::insert newClass -->">Text</i>'
          newClass: 'classy'
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
        reply.view('main',
          foobar: [1,2,3]
        )
      config:
        state:
          parse: false
          failAction: 'ignore'
    )
    
    
    server.route(
      method: 'GET'
      path: '/3'
      handler: (request, reply) ->
        reply.view('main',
          foobar: 
            stuff:'bar'
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
  
  it('Should insert vars - string', (done)->
    request('http://localhost:8000', (err, response, body)->
      expect(body).to.equal("""
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
      <span><i class="classy">Text</i></span>
      <h1>Header</h1>
      <!-- foo bar -->
        </body>
      </html>
      """)
      
      done()
    )  
  )
  
  
  it('Should insert vars - array', (done)->
    request('http://localhost:8000/2', (err, response, body)->
      expect(body).to.equal("""
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
      <span>[1,2,3]</span>
      <h1>Header</h1>
      <!-- foo bar -->
        </body>
      </html>
      """)
      
      done()
    )  
  )
  
  it('Should insert vars - object', (done)->
    request('http://localhost:8000/3', (err, response, body)->
      expect(body).to.equal("""
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
      <span>{&quot;stuff&quot;:&quot;bar&quot;}</span>
      <h1>Header</h1>
      <!-- foo bar -->
        </body>
      </html>
      """)
      
      done()
    )  
  )

)