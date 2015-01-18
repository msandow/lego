path = require('path')
async = require('async')
fs = require('fs')
define = require(__dirname + '/define.coffee')
_sync = require(__dirname + '/sync.coffee')
_eval = require(__dirname + '/eval.coffee')

req =
  regexp: new RegExp('lego::require\\s+([\\S]*)', 'i')
  fetchedTemplates: {}
  

req.findComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and req.regexp.test(el.data.trim())
  )

req.clean = ($) ->
  $('lego').each((idx, el)->
    $(el).replaceWith($(el).contents())
  )
  $.html()

req.recurse = ($, ctx, root, finished) ->
  includePaths = {}

  includes = req.findComments($)

  if includes.length
    includes.each((i, el) ->
      absPath = req.resolve(el, root, ctx)
      
      includePaths[absPath] = (cb) ->
        req.fetchedTemplates[absPath] = ''
      
        if not req.fetchedTemplates[absPath]
          fs.exists(absPath, (exists)->
            if not exists
              console.warn('Template',absPath,'not found')
              cb(null, req.fetchedTemplates[absPath])
            else
              ext = path.extname(absPath)

              switch ext
                when '.html'
                  fs.readFile(absPath, (err, data) ->
                    req.fetchedTemplates[absPath] = data.toString()
                    cb(null, req.fetchedTemplates[absPath])
                  )
                when '.js', '.coffee'
                  tempInclude = require(absPath)
                  
                  if tempInclude.compileMode is undefined or tempInclude.render is undefined
                    console.log('Template',absPath,'does not have compileMode / render')
                    cb(null, req.fetchedTemplates[absPath])
                  else
                    switch tempInclude.compileMode
                      when 'sync'
                        req.fetchedTemplates[absPath] = tempInclude.render()
                        cb(null, req.fetchedTemplates[absPath])
                      when 'async'
                        tempInclude.render((resp)->
                          req.fetchedTemplates[absPath] = resp
                          cb(null, req.fetchedTemplates[absPath])
                        )
                else
                  console.warn('Extension missing from',absPath)
                  cb(null, req.fetchedTemplates[absPath])
                  
          )
        else
          cb(null, fetchedTemplates[absPath])
    )

    async.parallel(includePaths, (err, results) ->
      includes.each((i, el)->
        absPath = req.resolve(el, root, ctx)
        if req.fetchedTemplates[absPath] isnt undefined
          $(el).replaceWith($(req.fetchedTemplates[absPath]))
      )
      
      define.recurse($, ctx)
      _sync.recurse($, ctx)
      
      if req.findComments($).length
        req.recurse($, ctx, root, finished)
      else
        finished(req.clean($))
    )
  else
    define.recurse($, ctx)
    _sync.recurse($, ctx)
  
    finished(req.clean($))

req.resolve = (el, root, ctx) ->
  relPath = el.data.trim().replace(req.regexp, '$1')
  _e = _eval(relPath, ctx)
  
  if typeof _e is 'function'
    _e = _e()
  
  if typeof _e isnt 'string'
    _e = false
  
  if _e then path.resolve(root, _e) else path.resolve(root, relPath)

module.exports = req