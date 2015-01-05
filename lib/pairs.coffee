module.exports = (root, $, ctx, openingTag, closingTag, topLevelResolver, subLevelResolver = false) ->
  
  isOpenSection = (i) ->
    i.type is 'comment' and openingTag.test(i.data.trim())
  
  isCloseSection = (i) ->
    i.type is 'comment' and closingTag.test(i.data.trim())
  
  openFetch = (i) ->
    i.data.trim().replace(openingTag, '$1')
  
  applyPairs = (root, $, ctx) ->
    fullSet = []

    walkTree = (item) ->
      item.parent().contents().filter((i, el)->
        root(el).parent().get(0) is item.parent().get(0)
      ).each((i, el)->
        _el = root(el)
        fullSet.push(el)

        if _el.contents().length
          walkTree(_el.contents().eq(0))
      )


    walkTree($)
    start = 0

    for e,i in fullSet
      start = i if e is $.get(0)

    fullSet = fullSet.slice(start)
    open = 0
    parent = false

    #
    # Logical tree for finding parent - children relationship

    for el,i in fullSet
      if isOpenSection(el)
        if subLevelResolver and open > 0
          el.data = el.data.replace(openFetch(el), openFetch(parent) + '.' + openFetch(el))
          applyPairs(root, root(el), ctx)
        
        parent = el
        open++

      if isCloseSection(el)
        open--
        if open is 0
          break


    #
    # Tree for proper insertion into trees through cheerio

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
    topLevelResolver(fullSet)

  applyPairs(root, $, ctx)