path = require('path')
async = require('async')
fs = require('fs')
insert = require(__dirname + '/insert.coffee')
_if = require(__dirname + '/if.coffee')
_notif = require(__dirname + '/notif.coffee')

req = 
  regexp: new RegExp('lego::require\\s+(.*?)', 'i')
  fetchedTemplates: {}

req.findComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and req.regexp.test(el.data.trim())
  )

req.recurse = ($, ctx, root, finished) ->
  includePaths = {}
  
  includes = req.findComments($)
  
  if includes.length
    includes.each((i, el) ->
      absPath = req.resolve(el, root)
      
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
          )
        else
          cb(null, fetchedTemplates[absPath])
    )

    async.parallel(includePaths, (err, results) ->
      includes.each((i, el)->
        absPath = req.resolve(el, root)
        if req.fetchedTemplates[absPath]
          $(el).replaceWith($(req.fetchedTemplates[absPath]))
      )

      insert.recurse($, ctx)
      _if.recurse($, ctx)
      _notif.recurse($, ctx)
      
      if req.findComments($).length
        req.recurse($, ctx, root, finished)
      else
        finished($.html())
    )  
  else
    insert.recurse($, ctx)
    _if.recurse($, ctx)
    _notif.recurse($, ctx)
  
    finished($.html())

req.resolve = (el, root) ->
  relPath = el.data.trim().replace(req.regexp, '$1')
  path.resolve(root, relPath)

module.exports = req