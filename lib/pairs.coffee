module.exports = (root, $, ctx, openingTag, closingTag, topLevelResolver, subLevelResolver = false) ->
  
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
        applyPairs(root, root(el), subLevelResolver(root(el))) if subLevelResolver
        open++

      if isCloseSection(el)
        open--
        if open is 0
          end = i+1
          return false
    )

    fullSet = fullSet.slice(0,end)
    topLevelResolver(fullSet)
    
  applyPairs(root, $, ctx)