module.exports = (root, $, ctx, openingTag, closingTag, topLevelResolver) ->
  
  isOpenSection = (i) ->
    i.type is 'comment' and openingTag.test(i.data.trim())
  
  isCloseSection = (i) ->
    i.type is 'comment' and closingTag.test(i.data.trim())
  
  openFetch = (i) ->
    i.data.trim().replace(openingTag, '$1')
  
  applyPairs = (root, $, ctx) ->
    fullSet = $.parent().contents()
    start = fullSet.index($)
    end = 1
    fullSet = fullSet.slice(start)
    open = 0

    fullSet.each((i, el)->
      if isOpenSection(el)
        open++

      if isCloseSection(el)
        open--
        if open is 0
          end = i+1
          return false
    )

    fullSet = fullSet.slice(0,end)
    topLevelResolver(fullSet) if fullSet.length

  applyPairs(root, $, ctx)