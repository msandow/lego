_eval = require(__dirname + '/eval.coffee')
cheerio = require('cheerio')

isHTML = (str)->
  body = cheerio.load('<body></body>')('*').first()
  body.append(str)
  !!body.children().length

_use =
  regexp: new RegExp('lego::use\\s+([\\S]*)\\s+with\\s+([\\S]*)', 'i')

_use.name = '_use'

_use.findComments = ($) ->
  $('*').contents().filter((i, el) ->
    (el.type is 'comment' and _use.regexp.test(el.data.trim()))
  )

_use.recurse = ($, ctx) ->
  uses = _use.findComments($)
  
  uses.each((i, el) ->
    $(el).replaceWith(_use.resolve($, el, ctx))
  )
  
  if _use.findComments($).length
    _use.recurse($, ctx)
  
  $

_use.resolve = (root, el, ctx) ->
  fetchVar = (_var) ->
    _eval(_var, ctx)

  _template = el.data.trim().replace(_use.regexp, '$1')
  _data = el.data.trim().replace(_use.regexp, '$2')

  if _template.length and _data.length
    _template = fetchVar(_template)
    _data = fetchVar(_data)
    
    if not isHTML(_template)
      console.warn('First item passed to lego::use must be a valid HTML template')
      return ''
    
    if _data
      stamp = cheerio.load(_template)
      
      _use._sync.recurse(stamp, _data)
      return stamp.html()
  
  return ''


module.exports = _use