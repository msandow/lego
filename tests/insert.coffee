config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'Insert'
  tests:[
    name: 'Should insert vars - string'
    file: 'main'
    ctx:
      foobar: '<!-- lego::insert next -->'
      next: '<i class="<!-- lego::insert newClass -->">Text</i>'
      newClass: 'classy'
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
            <span><i class="classy">Text</i></span>
            <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """
  ,
    name: 'Should insert vars - array'
    file: 'main'
    ctx:
      foobar: [1,2,3]
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
            <span>[1,2,3]</span>
            <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """
  ,
    name: 'Should insert vars - object'
    file: 'main'
    ctx:
      foobar: 
        stuff:'bar'
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
            <span>{&quot;stuff&quot;:&quot;bar&quot;}</span>
            <h1>Header</h1>
          <!-- foo bar -->
        </body>
      </html>
      """
  ,
    name: 'Should insert vars - nested'
    file: 'main_nested'
    ctx:
      foo: 'foo' 
      bar:
        baz: 'baz'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>foo</p>
          <p>baz</p>
        </body>
      </html>
      """
  ]

config.buildSuite(suite)