cheerio = require('cheerio')
path = require('path')

findIncludes = ($, root) ->
  comments = $('*').contents().filter((i, el) ->
    el.type is 'comment'
  )
  
  comments.each((i, el) ->
    #console.log($(@))
    relPath = el.data.trim().replace(/>\s*(.*?)/i, '$1')
    absPath = path.resolve(root, relPath)
    console.log(relPath, absPath)
  )

module.exports = 
  compile: (template, options, callback) ->
    #console.log(template)
    #console.log(options)
    
    findIncludes(cheerio.load(template), options.filename)
    
    callback(null, (ctx, opts,cb) ->
      cb(null, template)
    )