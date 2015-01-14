_eval = require(__dirname + '/eval.coffee')

insert = 
  regexp: new RegExp('lego::insert\\s+(.*?)', 'i')
  subTreeRegexp: new RegExp('(<|&lt;)!-- lego::insert\\s+(.*?) --(>|&gt;)', 'gim')

insert.findComments = ($) ->
  $('*').contents().filter((i, el) ->
    (el.type is 'comment' and insert.regexp.test(el.data.trim())) or do ->
      hasAttr = false
      
      if el.attribs
        for own k,v of el.attribs
          hasAttr = true if insert.regexp.test(v)
      
      hasAttr
  )

insert.recurse = ($, ctx) ->
  
  inserts = insert.findComments($)
  
  inserts.each((i, el) ->
    $(el).replaceWith(insert.resolve(el, ctx))
  )
  
  if insert.findComments($).length
    insert.recurse($, ctx)
  
  $

insert.resolve = (el, ctx) ->
  fetchVar = (_var) ->
    e = _eval(_var, ctx)

    if typeof e is 'object'
      if e.$this is undefined
        e = JSON.stringify(e)
      else
        e = JSON.stringify(e.$this)
    if typeof e is 'number'
      e = String(e)
    if typeof e is 'function'
      e = e()
      
    return e

  if el.type is 'comment'
    _var = el.data.trim().replace(insert.regexp, '$1')
    return fetchVar(_var)
  else
    for own k,v of el.attribs
      if insert.regexp.test(v)
        _var = v.trim().replace(insert.subTreeRegexp, '$2')
        el.attribs[k] = fetchVar(_var)
    return el


module.exports = insert