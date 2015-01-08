pairs = require(__dirname + '/pairs.coffee')
cheerio = require('cheerio')
insert = require(__dirname + '/insert.coffee')
_if = require(__dirname + '/if.coffee')

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

_fe.resolvedParser = (fullSet, ctx) ->
  resolved = _fe.resolve(fullSet.get(0), ctx)
  
  if not resolved
    fullSet.remove()
  else
    newNode = cheerio.load('<body></body>')('*').first()
    stamp = fullSet.slice(1,-2)
    i = 0

    while i < resolved.length
      if Array.isArray(resolved[i])
        _fe.resolvedParser(resolved[i], stamp, newNode)
      else
        cloned = cheerio.load('<body></body>')
        cloned('*').first().append(stamp.clone())

        if _fe.findOpenComments(cloned)
          _fe.recurse(cloned,resolved[i])          
        

        insert.recurse(cloned, resolved[i], ctx)
        _if.recurse(cloned, resolved[i])
        newNode.append(cloned.html())
      i++

    fullSet.replaceWith(newNode.find('body').contents())


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
          _fe.resolvedParser(
            fullSet,
            ctx
          )
      )

      if _fe.findOpenComments($).length
        _fe.recurse($, ctx)
    else
      console.warn('Unmatched number of foreach and endforeachs')
  
  $

_fe.resolve = (el, ctx) ->
  data = el.data.trim()
  _var = data.replace(_fe.openRegexp, '$1')
  
  #console.log(_var, ctx[_var])
  
  if /\w\.\w/i.test(_var)
    _var = _var.split('.')
    for sub in _var
      if ctx[sub]
        ctx = ctx[sub]
      else
        return false
    
    return ctx
  else
    if ctx[_var] and Array.isArray(ctx[_var]) and ctx[_var].length > 0
      return ctx[_var]
    else if typeof ctx[_var] is 'object'
      newArr = []
      
      for own k,v of ctx[_var]
        newArr.push({'$key':k, '$value':v})
      
      return newArr
    else
      return false

module.exports = _fe