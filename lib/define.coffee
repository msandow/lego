pairs = require(__dirname + '/pairs.coffee')
cheerio = require('cheerio')

define =
  openRegexp: new RegExp('lego::\\s*define\\s+([\\S]*)', 'i')
  closeRegexp: new RegExp('lego::\\s*enddefine\\s*', 'i')

define.findOpenComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and define.openRegexp.test(el.data.trim())
  )

define.findCloseComments = ($) ->
  $('*').contents().filter((i, el) ->
    el.type is 'comment' and define.closeRegexp.test(el.data.trim())
  )

define.recurse = ($, ctx) ->
  ifs = define.findOpenComments($)
  eifs = define.findCloseComments($)

  if ifs.length or eifs.length
    if ifs.length is eifs.length
      
      pairs(
        $,
        ifs,
        ctx,
        define.openRegexp,
        define.closeRegexp,
        (fullSet)->
          newPar = cheerio.load('<body></body>')('*').first()
          newPar.append(fullSet.slice(1,-1).clone())
          define.resolve(fullSet.get(0), ctx, newPar.html())
          
          newPar.remove()
          fullSet.remove()
      )

      if define.findOpenComments($).length
        define.recurse($, ctx)
    else
      console.warn('Unmatched number of ifs and endifs')
      ifs.add(eifs).remove()
  
  $

define.resolve = (el, ctx, addition) ->
  _var = el.data.trim().replace(define.openRegexp, '$1')

  ctx[_var] = addition

module.exports = define