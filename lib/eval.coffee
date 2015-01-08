module.exports = (post, operator, value) ->
  switch operator
    when ">"
      post > value
    when "<"
      post < value
    when ">="
      post >= value
    when "<="
      post <= value
    when "=="
      post is value
    when "!="
      post isnt value
    when "===", 'is'
      post is value
    when "!==", 'isnt'
      post isnt value