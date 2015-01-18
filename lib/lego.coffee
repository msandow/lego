cheerio = require('cheerio')
path = require('path')
fs = require('fs')
req = require(__dirname + '/require.coffee')
_ctx = require(__dirname + '/context.coffee')

attachedDir = __dirname

module.exports =
  attach: (server, templates) ->
    if server.views and server.version
      # Hapi
      
      attachedDir = templates

      server.views(
        engines:
          html: @
        path: templates
        compileMode: 'async'
        isCached: false
      )
    else if server.engines and server.mountpath
      # Express
      
      server.engine('html', (filePath, options, callback) =>
        ctx = {}
        for own k,v of options
          ctx[k] = v if ['settings','_locals','cache'].indexOf(k) is -1
      
        @render(filePath, ctx, (renderedTemplate)->
          callback(null, renderedTemplate)
        )
      )
      
      server.set('views', templates)
      server.set('view engine', 'html')
  
  render: (filePath, ctx, callback) ->
    fs.readFile(filePath, (err, contents)->
      req.recurse(
        cheerio.load('<lego>' + contents.toString() + '</lego>'),
        _ctx.build(ctx),
        if ctx.templatesRoot then path.resolve(attachedDir, ctx.templatesRoot) else path.dirname(filePath),
        (renderedTemplate)->
          callback(renderedTemplate)
      )
    )
  
  compile: (template, options, callback) ->
    callback(null, (ctx, opts, cb) ->
      req.recurse(
        cheerio.load('<lego>' + template + '</lego>'),
        _ctx.build(ctx),
        if ctx.templatesRoot then path.resolve(attachedDir, ctx.templatesRoot) else path.dirname(options.filename),
        (renderedTemplate)->
          cb(null, renderedTemplate)
      )
    )