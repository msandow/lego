module.exports = (root, $, ctx, openingTag, closingTag, resolver) ->
  
  isOpenSection = (i) ->
    i.type is 'comment' and openingTag.test(i.data.trim())
  
  isCloseSection = (i) ->
    i.type is 'comment' and closingTag.test(i.data.trim())
  
  
  applyPairs = (root, $, ctx) ->
    fullSet = $.parent().contents()
    start = fullSet.index($)
    end = 1
    fullSet = fullSet.slice(start)
    open = 0

    fullSet.each((i, el)->
      if isOpenSection(el)
        open++
        if open > 1
          applyPairs(root, root(el), ctx)

      if isCloseSection(el)
        open--
        if open is 0
          end = i+1
          return false
    )

    fullSet = fullSet.slice(0,end)
    resolver(fullSet)
    
  applyPairs(root, $, ctx)