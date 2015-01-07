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

insert.recurse = ($, ctx, rootctx=false) ->
  rootctx = ctx if not rootctx
  
  inserts = insert.findComments($)
  
  inserts.each((i, el) ->
    $(el).replaceWith(insert.resolve(el, ctx, rootctx))
  )
  
  if insert.findComments($).length
    insert.recurse($, ctx)
  
  $

insert.resolve = (el, ctx, rootctx) ->
  fetchVar = (_var) ->
 
    if /\w\.\w/i.test(_var)
      arr = _var.split('.')
    
      if arr[0] is '$root'
        ctx = rootctx
        return fetchVar(arr.slice(1).join('.'))
      else if ctx[arr[0]] and typeof ctx[arr[0]] is 'object'
        ctx = ctx[arr[0]]
        return fetchVar(arr.slice(1).join('.'))
      else
        return ''
    else if _var is '$this'
      if Array.isArray(ctx) or typeof ctx is 'object'
        return JSON.stringify(ctx)
      else
        return String(ctx)
    else if ctx[_var]
      if Array.isArray(ctx[_var]) or typeof ctx[_var] is 'object'
        return JSON.stringify(ctx[_var])
      else
        return String(ctx[_var])
    else
      return ''

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