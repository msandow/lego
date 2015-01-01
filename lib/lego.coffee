cheerio = require('cheerio')
path = require('path')
req = require(__dirname + '/require.coffee')


attachedDir = __dirname

module.exports = 
  attach: (server, templates) ->
    attachedDir = templates
    
    server.views(
      engines: 
        html: @
      path: templates
      compileMode: 'async'
      isCached: false
    )
    
  compile: (template, options, callback) ->
    callback(null, (ctx, opts, cb) ->
      req.recurse(
        cheerio.load(template),
        ctx,
        if ctx.templatesRoot then path.resolve(attachedDir, ctx.templatesRoot) else path.dirname(options.filename),
        (renderedTemplate)->
          req.fetchedTemplates = {}
          cb(null, renderedTemplate)
      )
    )