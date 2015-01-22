config = require(__dirname + '/config.coffee')

suite =
  suiteName: 'Sites'
  tests:[
    name: 'Should make forum site'
    file: 'full_body'
    ctx:
      title: 'My Forum'
      scripts: [
        'js/file1.js'
        'js/file2.js'
      ]
      forceHeader: true
      currentPage: 2
      pagination: do ->
        [0,1,2,3,4]
      pageBody: () ->
        'full_body_forum.html'
      userName: 'Mr. Bob'
      userID: 234323
    expected: """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>My Forum</title>
          <script type="text/javascript" src="js/file1.js"></script>
          <script type="text/javascript" src="js/file2.js"></script>
        </head>
        <body>
          <h1>Welcome</h1>
          
          <a href="user/234323">Mr. Bob</a>
          
          <ul class="pagination">
            <li>0</li>
            <li>1</li>
            <li class="active">2</li>
            <li>3</li>
            <li>4</li>
          </ul>
        </body>
      </html>
      """
  ,
    name: 'Should strip properly formatted tags'
    file: 'main_strip'
    ctx: {}
    expected: """
      
      """
  ]

config.buildSuite(suite)