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
            newNode = cheerio.load('<div></div>')('*').first()

            i = 0
            while i < resolved.length
              cloned = cheerio.load('<div></div>')
              cloned('*').first().append(stamp.clone())

              insert.recurse(cloned, resolved[i])
              newNode.append(cloned('*').contents())
              i++
            
            fullSet.replaceWith(newNode.children())
      )

      if _fe.findOpenComments($).length
        _fe.recurse($, ctx)
    else
      console.warn('Unmatched number of foreach and endforeachs')
  
  $

_fe.resolve = (el, ctx) ->
  _var = el.data.trim().replace(_fe.openRegexp, '$1')

  if ctx[_var] and Array.isArray(ctx[_var]) and ctx[_var].length > 0
    return ctx[_var]
  else
    return false

module.exports = _fe