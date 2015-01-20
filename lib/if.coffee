pairs = require(__dirname + '/pairs.coffee')
_eval = require(__dirname + '/eval.coffee')

_if =
  openRegexp: new RegExp('lego::(if|notif)\\s+(.*)', 'i')
  closeRegexp: new RegExp('lego::endif\\s*', 'i')
  isString: new RegExp('("|&quot;|\'|&apos;)([\\w]*)("|&quot;|\'|&apos;)', 'i')
  elses: new RegExp('lego::else\\s*', 'i')

_if.name = '_if'

_if.findOpenComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _if.openRegexp.test(el.data.trim())
  )

_if.findCloseComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _if.closeRegexp.test(el.data.trim())
  )

_if.findElseComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and _if.elses.test(el.data.trim())
  )

findParentIf = ($)->
  el = $.prev
  
  return false if not el
  
  return if el.type and el.type is 'comment' and _if.openRegexp.test(el.data.trim()) then el else findParentIf(el)

_if.expandElses = ($, ctx) ->
  elses = _if.findElseComments($)
  
  elses.each((idx, el)->
    p = findParentIf(el)
    if p
      _case = p.data.trim().replace(_if.openRegexp, '$1')
      newComment = p.data.trim()
      
      if _case is 'if'
        newComment = newComment.replace(/lego::if/, 'lego::notif')
      else
        newComment = newComment.replace(/lego::notif/, 'lego::if')
      
      $(el).replaceWith('<!-- lego::endif --><!-- ' + newComment + ' -->')
    else
      $(el).remove()
  )


_if.recurse = ($, ctx) ->

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
          if not _if.resolve(fullSet.get(0), ctx)
            fullSet.remove()
          else
            fullSet.eq(0).remove()
            fullSet.eq(-1).remove()
      )

      if _if.findOpenComments($).length
        _if.recurse($, ctx)
    else
      console.warn('Unmatched number of ifs and endifs')
      ifs.add(eifs).remove()
  
  $


_if.resolve = (el, ctx) ->
  _case = el.data.trim().replace(_if.openRegexp, '$1')
  _var = el.data.trim().replace(_if.openRegexp, '$2')
  
  getState = (v) ->
    if Array.isArray(v)
      return v.length > 0
    else
      return !!v
  
  _var = _var.replace(/(\[\d+\])(\s|$)/gi, '.$this$1')
  state = getState(_eval(_var, ctx))

  if _case is 'notif' then !state else state

module.exports = _if