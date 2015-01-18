module.exports = (str, ctx) ->
  try
    e = (new Function("with(this){return #{str}}")).call(ctx)
    
    if e is undefined
      e = false

    return e
  catch e
    return false