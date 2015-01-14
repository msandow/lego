module.exports = (str, ctx) ->
  try
    e = (new Function("with(this){return #{str}}")).call(ctx)
    
    return e
  catch e
    return false