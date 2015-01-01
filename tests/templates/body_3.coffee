module.exports = 
  compileMode: 'async'
  render: (cb)->
    setTimeout(()->
      cb("""
      <!-- lego::require ./header.html  -->
      <!-- lego::insert baz -->
      """)
    ,1000)