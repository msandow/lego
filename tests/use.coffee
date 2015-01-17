config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'Use'
  tests:[
    name: 'Should use defined templates'
    file: 'main_use'
    ctx:
      obj1:
        name: 'Bob'
        age: 30
      obj2:
        name: 'Greg'
        age: 40
      title: 'Page Title'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Page Title</title>
        </head>
        <body>
          <div>
            <h1>Header</h1>
            <!-- foo bar -->
            <b>Bob</b>
            <i>30</i>
          </div>
          <div>
            <h1>Header</h1>
            <!-- foo bar -->
            <b>Greg</b>
            <i>40</i>
          </div>
        </body>
      </html>
      """
  ,
    name: 'Should ignore non-HTML'
    file: 'main_use_2'
    ctx:
      obj1: 50
      arr: [
        1, 2, 3
      ]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>1</p>
          <p>2</p>
          <p>3</p> 
          <p>50</p> 
          <p>50</p> 
          <p>50</p> 
        </body>
      </html>
      """
  ]

config.buildSuite(suite)