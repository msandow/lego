_eval = require(__dirname + '/eval.coffee')

insert =
  regexp: new RegExp('lego::\\s*insert\\s+([\\S]*)', 'i')
  subTreeRegexp: new RegExp('(.*?)(<|&lt;)!-- lego::\\s*insert\\s+'+
    '([\\S]*) --(>|&gt;)(.*?)', 'gim')

insert.name = '_insert'

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
    $(el).replaceWith(insert.resolve($, el, ctx))
  )
  
  if insert.findComments($).length
    insert.recurse($, ctx)
  
  $

insert.resolve = (root, el, ctx) ->
  fetchVar = (_var) ->
    if typeof ctx is 'string' or typeof ctx is 'number' and _var is '$this'
      return String(ctx)
  
    e = _eval(_var, ctx)

    if typeof e is 'object' and e.$this isnt undefined
      e = e.$this
    else if typeof e is 'number'
      e = String(e)
    else if typeof e is 'function'
      e = e()
    else if typeof e is 'boolean'
      e = ''
      
    if typeof e is 'object'
      e = JSON.stringify(e)
      
    return e
  
  if el.type is 'comment'
    _var = el.data.trim().replace(insert.regexp, '$1')
    return fetchVar(_var)
  else
    rep = root(el).clone()
    attrs = rep.get(0).attribs

    for own k,v of attrs
      if insert.regexp.test(v)
        _var = v.trim().replace(insert.subTreeRegexp, '$3')
        rep.attr(k, v.trim().replace(insert.subTreeRegexp, '$1'+fetchVar(_var)+'$5'))

    return rep


module.exports = insert