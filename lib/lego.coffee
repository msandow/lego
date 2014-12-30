cheerio = require('cheerio')
path = require('path')
fs = require('fs')
async = require('async')

fetchedTemplates = {}

includesRegExp = new RegExp('>\\s*(.*?)', 'i')


findIncludComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and includesRegExp.test(el.data.trim())
  )


resolvePath = (el, root) ->
  relPath = el.data.trim().replace(includesRegExp, '$1')
  path.resolve(root, relPath)


findIncludes = ($, root, finished) ->
  includePaths = {}

  includes = findIncludComments($)
  
  if includes.length    
    includes.each((i, el) ->
      absPath = resolvePath(el, root)

      includePaths[absPath] = (cb) ->
        if not fetchedTemplates[absPath]
          fs.exists(absPath, (exists)->
            if not exists
              fetchedTemplates[absPath] = false
              console.warn('Template',absPath,'not found')
              cb(null, false)
            else
              fs.readFile(absPath, (err, data) ->
                fetchedTemplates[absPath] = $(data.toString())
                cb(null, fetchedTemplates[absPath])
              )
          )
        else
          cb(null, fetchedTemplates[absPath])
    )

    async.parallel(includePaths, (err, results) ->
      #console.log(results)
      includes.each((i, el)->
        absPath = resolvePath(el, root)
        if fetchedTemplates[absPath]
          $(el).replaceWith(fetchedTemplates[absPath])
      )

      if findIncludComments($).length
        findIncludes($, root, finished)
      else
        finished($.html())
    )  
  else  
    finishes($.html())


module.exports = 
  attach: (server, templates) ->
    server.views(
      engines: 
        html: @
      path: templates
      compileMode: 'async'
      isCached: false
    )
    
  compile: (template, options, callback) ->
    #console.log(template)
    #console.log(options)
    
    findIncludes(cheerio.load(template), path.dirname(options.filename), (renderedTemplate)->
      callback(null, (ctx, opts,cb) ->
        fetchedTemplates = {}
        cb(null, renderedTemplate)
      )
    )