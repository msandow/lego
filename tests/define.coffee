config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'Define'
  tests:[
    name: 'Should iterate through defined value'
    file: 'main_define'
    ctx:
      arr: [1,2,3]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <table class="1"></table>
          <table class="2"></table>
          <table class="3"></table>
          
          <div><p>Hello</p></div>
        </body>
      </html>
      """
  ,
    name: 'Should chain defined values'
    file: 'main_define_2'
    ctx:
      thing: 'hello'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p><span>hello</span></p>
        </body>
      </html>
      """
  ]

config.buildSuite(suite)