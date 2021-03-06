require('mocha')
expect = require('chai').expect
hapi = require('hapi')
express = require('express')
request = require('request')
lego = require(__dirname + '/../lego.js')
_ctx = require(__dirname + '/../lib/context.coffee')


module.exports =
  port: 3333
  cleanHTML: (str) ->
    str.replace(/(\n|\t|\s{2,})/g ,'')
  
  buildSuite: (suite) ->

    # Hapi tests

    describe(suite.suiteName + ' - Hapi', =>
      server = new hapi.Server()
      
      before(()=>
        server.connection(
          port: @port
        )

        lego.attach(server, __dirname + '/templates/')
        
        for t,idx in suite.tests
          do (t, idx) ->
            server.route(
              method: 'GET'
              path: '/'+idx
              handler: (request, reply) ->
                reply.view(t.file, _ctx.clone(t.ctx))
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
      
      for t,idx in suite.tests
        do (t, idx) =>
          it(t.name, (done)=>
            request('http://localhost:'+@port+'/'+idx, (err, response, body)=>
              expect(@cleanHTML(body)).to.equal(@cleanHTML(t.expected))

              done()
            )  
          )
    )
    
    # Express tests
    
    describe(suite.suiteName + ' - Express', =>
      app = express()
      server = null

      before(()=>
        lego.attach(app, __dirname + '/templates/')
        
        for t,idx in suite.tests
          do (t, idx) ->
            app.get('/'+idx, (req, res)->
              res.render(t.file, _ctx.clone(t.ctx))
            )

        server = app.listen(@port)
      )

      after(()->
        server.close()
      )
      
      for t,idx in suite.tests
        do (t, idx) =>
          it(t.name, (done)=>
            request('http://localhost:'+@port+'/'+idx, (err, response, body)=>
              expect(@cleanHTML(body)).to.equal(@cleanHTML(t.expected))

              done()
            )  
          )
    )