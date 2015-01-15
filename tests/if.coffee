config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'If'
  tests:[
    name: 'Should not include header'
    file: 'main_if'
    ctx:
      showHeader: false
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>Bar</p>
        </body>
      </html>
      """
  ,
    name: 'Should include header'
    file: 'main_if'
    ctx:
      showHeader: [true]
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
    name: 'Should handle mixed ifs / notifs - negative'
    file: 'main_if_mixed'
    ctx:
      foo: ''
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
        </body>
      </html>
      """
  ,
    name: 'Should handle mixed ifs / notifs - positive'
    file: 'main_if_mixed'
    ctx:
      foo: 't'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
        </body>
      </html>
      """
  ,
    name: 'Should handle complex ifs'
    file: 'main_if'
    ctx:
      arr: [0,0,0]
      comp: 3
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>Bar</p>
          <p>Bar1</p>
          <p>Bar2</p>
          <p>Bar3</p>
        </body>
      </html>
      """
  ,
    name: 'Should handle empty string comparisons'
    file: 'main_if_2'
    ctx:
      one: ""
      two: "two"
      arr: [
        "str"
      ]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>Hello world</p>
          <p>Hello again</p>
          <p>Str</p>
        </body>
      </html>
      """
  ,
    name: 'Should include via function'
    file: 'main_if'
    ctx:
      computed: ()->
        'hello'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body> 
          <p>Bar</p>
          <p>hello</p>
        </body>
      </html>
      """
  ]

config.buildSuite(suite)