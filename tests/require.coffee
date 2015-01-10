config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'Require'
  tests:[
    name: 'Should require html documents'
    file: 'main'
    ctx: {}
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <h1>Header</h1>
          <!-- foo bar -->
            <p>Foo</p>
            <span></span>
            <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """
  ,
    name: 'Should require js sync documents'
    file: 'main_2'
    ctx: {}
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """
  ,
    name: 'Should require js async documents'
    file: 'sub/main_3'
    ctx: 
      templatesRoot: './'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """
  ]

config.buildSuite(suite)