module.exports = (str, ctx) ->
  try
    if str.indexOf('foo[0].$this[1].$this ===') > -1
      console.log(str)
      console.log(ctx.foo[0])
      process.exit(1)
    e = (new Function("with(this){return #{str}}")).call(ctx)
    if e is undefined
      e = false
    return e
  catch e
    return false