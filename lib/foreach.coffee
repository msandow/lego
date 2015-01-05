pairs = require(__dirname + '/pairs.coffee')
cheerio = require('cheerio')
insert = require(__dirname + '/insert.coffee')

_fe = 
  openRegexp: new RegExp('lego::foreach\\s+(.*?)', 'i')
  closeRegexp: new RegExp('lego::endforeach\\s*', 'i')

_fe.findOpenComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _fe.openRegexp.test(el.data.trim())
  )

_fe.findCloseComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _fe.closeRegexp.test(el.data.trim())
  )

_fe.resolvedParser = (resolved, stamp, newNode) ->
  i = 0
  
  while i < resolved.length
    if Array.isArray(resolved[i])
      _fe.resolvedParser(resolved[i], stamp, newNode)
    else
      cloned = cheerio.load('<body></body>')
      cloned('*').first().append(stamp.clone())

      insert.recurse(cloned, resolved[i])
      newNode.append(cloned.html())
    i++

  newNode


_fe.recurse = ($, ctx) ->
  fes = _fe.findOpenComments($)
  efes = _fe.findCloseComments($)

  if fes.length and efes.length
    if fes.length is efes.length

      pairs(
        $,
        fes,
        ctx,
        _fe.openRegexp,
        _fe.closeRegexp,
        (fullSet)->
          resolved = _fe.resolve(fullSet.get(0), ctx)

          if not resolved
            fullSet.remove()
          else
            stamp = fullSet.slice(1,-2)
            newNode = _fe.resolvedParser(
              resolved,
              stamp, 
              cheerio.load('<body></body>')('*').first()
            )

            fullSet.replaceWith(newNode.find('body').contents())
        , true
      )

      if _fe.findOpenComments($).length
        _fe.recurse($, ctx)
    else
      console.warn('Unmatched number of foreach and endforeachs')
  
  $

_fe.resolve = (el, ctx) ->
  data = el.data.trim()
  _var = data.replace(_fe.openRegexp, '$1')

  if /\w\.\w/i.test(_var)
    _var = _var.split('.')
    for sub in _var.slice(0,-1)
      if ctx[sub]
        ctx = ctx[sub]
      else
        return false
    
    _var = _var.slice(-1)[0]
    
    return ctx.map((i) ->
      i[_var]
    )

  else
    if ctx[_var] and Array.isArray(ctx[_var]) and ctx[_var].length > 0
      return ctx[_var]
    else
      return false

module.exports = _fe