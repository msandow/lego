pairs = require(__dirname + '/pairs.coffee')
cheerio = require('cheerio')
_eval = require(__dirname + '/eval.coffee')


_fe =
  openRegexp: new RegExp('lego::foreach\\s+([\\S]*)', 'i')
  closeRegexp: new RegExp('lego::endforeach\\s*', 'i')

_fe.name = '_fe'

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
      cloned = cheerio.load('<body></body>')
      cloned('*').first().append(stamp.clone())

      _fe._sync.recurse(cloned,resolved[i])
      newNode.append(cloned('body').html())
      i++

    fullSet.replaceWith(newNode.contents())


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
  
  e = _eval(_var, ctx)
  
  if typeof e is 'object' and not Array.isArray(e)
    newArr = []
      
    for own k,v of e
      if _fe._ctx.excludedKeys.indexOf(k) is -1
        newArr.push({'$key':k, '$value':v})
    
    return newArr
  
  return e

module.exports = _fe