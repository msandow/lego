require('mocha')
expect = require('chai').expect
hapi = require('hapi')
request = require('request')

lego = require(__dirname + '/../lego.js')
server = new hapi.Server()

port = 8000


describe('Foreach', ->
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
        reply.view('main_foreach_1',
          arr: [1,2,3]
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
        reply.view('main_foreach_1',
          obs: [
            {src: 'foo.jpg'},
            {src: 'bar.png'},
            {src: 'baz.gif'}
          ]
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
        reply.view('main_foreach_2',
          users: [
            {name: 'Bob',  roles: ['role1', 'role2']}
          ]
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
  
  it('Should iterate three times', (done)->
    request('http://localhost:8000', (err, response, body)->
      expect(body).to.equal("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          
            <img>
            <img>
            <img>
          
          
        </body>
      </html>
      """)
      
      done()
    )  
  )
  
  it('Should insert three attributes', (done)->
    request('http://localhost:8000/2', (err, response, body)->
      expect(body).to.equal("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          
          
          <img src="foo.jpg"><img src="bar.png"><img src="baz.gif">
        </body>
      </html>
      """)
      
      done()
    )  
  )

  it('Should insert sub tags', (done)->
    request('http://localhost:8000/3', (err, response, body)->
      expect(body).to.equal("""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Lego Test</title>
      </head>
      <body>
        
          <p>
            <b>Name:</b>Bob
            
              <br><span>role1</span>
              <br><span>role2</span>
          </p>
      </body>
    </html>
      """)
      
      done()
    )  
  )
)