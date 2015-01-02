pairs = require(__dirname + '/pairs.coffee')

_notif = 
  openRegexp: new RegExp('lego::notif\\s+(.*?)', 'i')
  closeRegexp: new RegExp('lego::endnotif\\s*', 'i')

_notif.findOpenComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _notif.openRegexp.test(el.data.trim())
  )

_notif.findCloseComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _notif.closeRegexp.test(el.data.trim())
  )

_notif.recurse = ($, ctx) ->
  nifs = _notif.findOpenComments($)
  eifs = _notif.findCloseComments($)

  if nifs.length and eifs.length
    if nifs.length is eifs.length
      
      pairs(
        $,
        nifs,
        ctx,
        _notif.openRegexp,
        _notif.closeRegexp,
        (fullSet)->
          if not _notif.resolve(fullSet.get(0), ctx)
            fullSet.remove()
          else
            fullSet.eq(0).remove()
            fullSet.eq(-1).remove()
      )

      if _notif.findOpenComments($).length
        _notif.recurse($, ctx)
    else
      console.warn('Unmatched number of notifs and endifs')
  
  $

_notif.resolve = (el, ctx) ->
  _var = el.data.trim().replace(_notif.openRegexp, '$1')
  if ctx[_var]
    if Array.isArray(ctx[_var])
      return ctx[_var].length is 0
    else
      return !!ctx[_var]
  else
    return true

module.exports = _notif