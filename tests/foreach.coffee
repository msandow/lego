config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'Foreach'
  tests:[
    name: 'Should iterate three times'
    file: 'main_foreach_1'
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
          <img>
          <img>
          <img>
          <div></div>
        </body>
      </html>
      """
  ,
    name: 'Should insert three attributes'
    file: 'main_foreach_1'
    ctx:
      obs: [
        {src: 'foo.jpg'},
        {src: 'bar.png'},
        {src: 'baz.gif'}
      ]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div>
            <img src="foo.jpg">
            <img src="bar.png">
            <img src="baz.gif">
          </div>
        </body>
      </html>
      """
  ,
    name: 'Should insert sub tags'
    file: 'main_foreach_2'
    ctx:
      users: [
        {name: 'Bob',  roles: ['role1', 'role2']}
      ]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p>
            <b>Name:</b>Bob
            <br><span>role1</span>
            <br><span>role2</span>
          </p>
        </body>
      </html>
      """
  ,
    name: 'Should insert sub tags multiple levels'
    file: 'main_foreach_3'
    ctx:
      foo:[
        {
          bar:[
            {
              baz:[
                {text:1},
                {text:2}
              ]
            }
          ]
        },
        {
          bar:[
            {
              baz:[
                {text:3},
                {text:4}
              ]
            }
          ]
        }
      ]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div>
            <p>
              <u>1</u>
              <u>2</u>
            </p>
          </div>
          <div>
            <p>
              <u>3</u>
              <u>4</u>
            </p>
          </div>
        </body>
      </html>
      """
  ,
    name: 'Should insert same level tags'
    file: 'main_foreach_4'
    ctx:
      name: 'Billy'
      includes: [1,1,1]
      stuff: ['<hr/>','<hr/>','<hr/>']
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div>
            <p>Billy</p>
            <h1>Header</h1>
            <!-- foo bar -->
            <h1>Header</h1>
            <!-- foo bar -->
            <h1>Header</h1>
            <!-- foo bar -->
            <hr>
            <hr>
            <hr>
          </div>
        </body>
      </html>
      """
  ,
    name: 'Should insert root level values'
    file: 'main_foreach_root'
    ctx:
      foo:'string'
      arr: [1,2,3,4]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <span>string</span>
          <span>string</span>
          <span>string</span>
        </body>
      </html>
      """
  ,
    name: 'Should insert object iterations'
    file: 'main_foreach_object'
    ctx:
      obj:
        'hello':'world'
        'foo':
          'bar':true
      arr:
        arr:[1,2,3]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <p><b>hello</b>world</p>
          <p><b>foo</b>{&quot;bar&quot;:true}</p>
          123123
        </body>
      </html>
      """
  ,
    name: 'Should traverse object iterations'
    file: 'main_foreach_traverse'
    ctx:
      obj:
        'arr':['a', 'b', 'c']
        'obj':
          'baz':true
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div>a</div>
          <div>b</div>
          <div>c</div>
        </body>
      </html>
      """
  ,
    name: 'Should traverse object in readme'
    file: 'main_foreach_readme'
    ctx:
      users:
        admins:[
          {
            'name': 'Mike'
          },
          {
            'name': 'Bob'
          }
        ]
      'class': 'userClass'
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          <div class="userClass">Mike</div>
          <div class="userClass">Bob</div>
        </body>
      </html>
      """
  ,
    name: 'Should serialize'
    file: 'main_foreach_serialize'
    ctx:
      list: [
        [1,2],
        {
          foo:
            stuff:'bar'
        }
      ]
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Lego Test</title>
        </head>
        <body>
          [1,2]<br>
          {&quot;foo&quot;:{&quot;stuff&quot;:&quot;bar&quot;}}<br>
        </body>
      </html>
      """
  ]

config.buildSuite(suite)