insert = 
  regexp: new RegExp('lego::insert\\s+(.*?)', 'i')

insert.findComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and insert.regexp.test(el.data.trim())
  )

insert.recurse = ($, ctx) ->
  inserts = insert.findComments($)
  
  inserts.each((i, el) ->
    $(el).replaceWith($(insert.resolve(el, ctx)))
  )
  
  if insert.findComments($).length
    insert.recurse($, ctx)
  
  $

insert.resolve = (el, ctx) ->
  _var = el.data.trim().replace(insert.regexp, '$1')
  ctx[_var] or '<!-- -->'

module.exports = insert