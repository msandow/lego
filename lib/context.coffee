module.exports = 

  excludedKeys: ['templatesRoot', '$this', '$parent', '$root']

  clone: (ob) ->
    JSON.parse(JSON.stringify(ob))

  build: (oo) ->
    oo.$this = @clone(oo)
    oo.$parent = oo
    oo.$root = oo

    walk = (ob, par, root) =>
      if Array.isArray(ob)
        ob.$this = @clone(ob)

        for it, idx in ob
          nob = {}
          nob.$this = if typeof it is 'object' then @clone(it) else it
          nob.$parent = ob
          nob.$root = root

          if typeof it is 'object'
            nob = walk(it, ob, root)

          ob[idx] = nob

      else
        ob.$this = @clone(ob)
        ob.$parent = par
        ob.$root = root

        for own k, v of ob
          if typeof v is 'object' and @excludedKeys.indexOf(k) is -1
            ob[k] = walk(v, ob, root)

      ob

    for own k, v of oo
      if typeof v is 'object' and @excludedKeys.indexOf(k) is -1
        oo[k] = walk(v, oo, oo)


    oo