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
  ,
    name: 'Should require fragments'
    file: 'main_fragment'
    ctx: 
      hello: 'world'
    expected: """
      <p>One</p>
      world
      """
  ,
    name: 'Should require dynamic value'
    file: 'main_require_dynamic'
    ctx: 
      path: 'main_require_dynamic_path.html'
      bar: 'hello'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>Foo</p>
          hello
        </body>
      </html>
      """
  ]

config.buildSuite(suite)