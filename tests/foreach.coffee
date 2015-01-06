require('mocha')
expect = require('chai').expect
hapi = require('hapi')
request = require('request')
config = require(__dirname + '/config.coffee')

lego = require(__dirname + '/../lego.js')
server = new hapi.Server()

describe('Foreach', ->
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
    
    server.route(
      method: 'GET'
      path: '/4'
      handler: (request, reply) ->
        reply.view('main_foreach_3',
          foo:[
            {
              bar:[
                {
                  baz:[
                    {text:1},
                    {text:2}
                  ]
                }
              ]
            },
            {
              bar:[
                {
                  baz:[
                    {text:3},
                    {text:4}
                  ]
                }
              ]
            }
          ]            
        )
      config:
        state:
          parse: false
          failAction: 'ignore'
    )
    
    server.route(
      method: 'GET'
      path: '/5'
      handler: (request, reply) ->
        reply.view('main_foreach_4',
          name: 'Billy'
          includes: [1,1,1]
          stuff: ['<hr/>','<hr/>','<hr/>']
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
    request('http://localhost:'+config.port, (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
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
      """))
      
      done()
    )  
  )
  
  it('Should insert three attributes', (done)->
    request('http://localhost:'+config.port+'/2', (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <img src="foo.jpg">
          <img src="bar.png">
          <img src="baz.gif">
        </body>
      </html>
      """))
      
      done()
    )  
  )

  it('Should insert sub tags', (done)->
    request('http://localhost:'+config.port+'/3', (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
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
      """))
      
      done()
    )  
  )
  
  it('Should insert sub tags', (done)->
    request('http://localhost:'+config.port+'/4', (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div>
            <p>
              <u>1</u>
              <u>2</u>
            </p>
          </div>
          <div>
            <p>
              <u>3</u>
              <u>4</u>
            </p>
          </div>
        </body>
      </html>
      """))
      
      done()
    )  
  )
  
  it('Should insert same level tags', (done)->
    request('http://localhost:'+config.port+'/5', (err, response, body)->
      expect(config.cleanHTML(body)).to.equal(config.cleanHTML("""
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div>
            <p>Billy</p>
            <h1>Header</h1>
            <!-- foo bar -->
            <h1>Header</h1>
            <!-- foo bar -->
            <h1>Header</h1>
            <!-- foo bar -->
            <hr>
            <hr>
            <hr>
          </div>
        </body>
      </html>
      """))
      
      done()
    )  
  )
)