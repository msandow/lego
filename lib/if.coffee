pairs = require(__dirname + '/pairs.coffee')
_eval = require(__dirname + '/eval.coffee')

_if = 
  openRegexp: new RegExp('lego::(if|notif)\\s+([\\S]*)\\s*([\\S]*)\\s*([\\S]*)', 'i')
  closeRegexp: new RegExp('lego::endif\\s*', 'i')
  isString: new RegExp('("|&quot;|\'|&apos;)([\\w]+)("|&quot;|\'|&apos;)', 'i')

_if.findOpenComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _if.openRegexp.test(el.data.trim())
  )

_if.findCloseComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _if.closeRegexp.test(el.data.trim())
  )

_if.recurse = ($, ctx , rootctx=false) ->
  rootctx = ctx if not rootctx

  ifs = _if.findOpenComments($)
  eifs = _if.findCloseComments($)

  if ifs.length and eifs.length
    if ifs.length is eifs.length
      
      pairs(
        $,
        ifs,
        ctx,
        _if.openRegexp,
        _if.closeRegexp,
        (fullSet)->
          if not _if.resolve(fullSet.get(0), ctx, rootctx)
            fullSet.remove()
          else
            fullSet.eq(0).remove()
            fullSet.eq(-1).remove()
      )

      if _if.findOpenComments($).length
        _if.recurse($, ctx)
    else
      console.warn('Unmatched number of ifs and endifs')
  
  $

_if.resolve = (el, ctx, rootctx) ->
  _case = el.data.trim().replace(_if.openRegexp, '$1')
  _var = el.data.trim().replace(_if.openRegexp, '$2')
  
  getState = (v) ->
    if Array.isArray(v)
      return v.length > 0
    else
      return !!v
  
  traverse = (arr, ctx) ->
    for o in arr
      if ctx[o]
        ctx = ctx[o]
      else
        ctx = false
        break
    ctx
  
  parse = (_var) ->
    if /\w\.\w/i.test(_var)
      arr = _var.split('.')
      if arr[0] is '$root'      
        state = traverse(arr.slice(1), rootctx)
      else if arr[0] is '$this'
        state = ctx  
      else
        state = traverse(arr, ctx)
    else
      if ctx[_var]
        state = ctx[_var]
      else
        state = false
    
    state
  
  if el.data.trim().replace(_if.openRegexp, '$3') and el.data.trim().replace(_if.openRegexp, '$4')
    op = el.data.trim().replace(_if.openRegexp, '$3')
    comp = el.data.trim().replace(_if.openRegexp, '$4')
    
    if _if.isString.test(comp)
      state = _eval(parse(_var), op, comp)
    else
      comp = if not /[\D]/i.test(comp) then parseInt(comp) else parse(comp)
      state = _eval(parse(_var), op, comp)
  else  
    state = getState(parse(_var))

  if _case is 'notif' then !state else state

module.exports = _if