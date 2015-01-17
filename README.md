![Lego](http://bucket.usastra.com/gallery/Web Resources/lego.png)

***Blocks. They're all blocks.***

Hapi *( >= 8)* and Express *( >= 4 )* HTML templating for files with .html extension. Similiar to Handlebars in its features, Lego allows for doing server-side includes of static HTML files or other JS files that return primitives, and the use of logical operators for conditionals. Think Handlebars, meets KnockoutJS, plus PHP-esque requiring.

[Server Implentation](#setup)

[View Templating Methods](#methods)

- [Define](#define)
- [Foreach](#foreach)
- [If / Notif](#if)

<p>&nbsp;</p>

___

<p>&nbsp;</p>

<a name="setup"></a>
## Server Implementation

To bind the rendering engine to your server of choice takes only a single call to the `attach` method:

```javascript
var lego = require('lego');

// Hapi server implementation
var hapi = require('hapi');
var server = new hapi.Server();

lego.attach(server, 'path_to_my/templates/');

server.connection({
  'port': 8000
});

// Express server implementation
var express = require('express');
var app = express();

lego.attach(app, 'path_to_my/templates/');

var server = app.listen(8000)
```

In both instances, `'path_to_my/templates/'` points to the directory where your HTML templates reside. When calling to render a view, the name of the view must directly map to an file with an .html extension of the same relative path inside this directory.

To invoke a view on a request to specific path, simply use the server-specific method of replying with your specific template file inside your configured templates directory (let's pretend you have a file who's path is `'path_to_my/templates/users.html'`:

```javascript
// Hapi server implementation
server.route({
  'method': 'GET',
  'path': '/users',
  'handler': function (request, reply){
    reply.view('users');
  }
});

// Express server implementation
app.get('/users', function(req, res){
  res.render('users');
});
```

Both the Hapi `view` and the Express `render` methods take a second, optional, object after the template name. This object is the content object used for any calls to Lego's `insert`/`if`/`foreach` methods.

Not using Hapi or Express? You can wire up Lego directly with the `render` method with this signature:
 
&nbsp; | &nbsp;
 --- | --- 
`filePath` | The path on disk for the template to load: `/Users/bob/lego/templates/index.html`
`ctx` | The contenxt object containing any optional key / value pairs to insert into your page
`callback` | The function to call when rendering is complete, which takes a single parameter that's the compiled HTML

```javascript
var lego = require('lego');
//Inside your particular request handler function

lego.render('my/file/path.html', {}, function(renderedTemplate){
    respond.with(renderedTemplate);
});
```

<p>&nbsp;</p>

___

<p>&nbsp;</p>

<a name="methods"></a>
## View Templating Methods

<p>&nbsp;</p>

<a name="define"></a>
### - Define

Define custom snippets of HTML inside templates to include with insert command.


**Examples:**

This defines a context-less block of code to be inserted anywhere

```html
<!-- lego::define customTemplate -->
  <div class="someBlockClass"></div>
<!-- lego::enddefine -->
```

Which when inserted like this...

```html
<!-- lego::insert customTemplate -->
```

Renders this...

```html
<div class="someBlockClass"></div>
```

<p>&nbsp;</p>

This defines a sub-template of code with a context, who's context will only be resolved when actually inserted

```html
<!-- lego::define customTemplate -->
  <div class="<!-- lego::insert $this -->"></div>
<!-- lego::enddefine -->
```

When inserted inside a foreach call on an context that looks like:

```javascript
context = {
  'arr': [1, 2, 3]
};
```

And invoked as such...

```html
<!-- lego::foreach arr -->
  <!-- lego::insert customTemplate -->
<!-- lego::endforeach -->
```

Renders this...

```html
<div class="1"></div>
<div class="2"></div>
<div class="3"></div>
```

<p>&nbsp;</p>

Be aware that using the `define` method essentially extends the context object fed to the `view`/`render` method with a new key matching the string provided. So it's possible to override any values in that object that have the same name.

Defined sub-templates are removed after definition, and never rendered unless inserted.

<p>&nbsp;</p>

<a name="foreach"></a>
### - Foreach

Iterate through arrays or objects, with the content of each of the loops being the single array element, or the single key/value pair in an object.

**Examples:**

Let's pretend we passed a context such as:

```javascript
context = {
  'users':{
    'admins': [
      {
        'name': 'Mike'
      },
      {
        'name': 'Bob'
      }
    ]
  },
  'class': 'userClass'
};
```

And invoke it as such...

```html
<!-- lego::foreach users.admins -->
  <div class="<!-- lego::insert $root.class -->"><!-- lego::insert name --></div>
<!-- lego::endforeach -->
```

Renders this...

```html
<div class="userClass">Mike</div>
<div class="userClass">Bob</div>
```

<p>&nbsp;</p>

Notice that the context of each div is the individual object being iterated through in the array, but that you can reference that entire context object inside that loop by using `$root`.

You can also iterate through object keys and values using special `$key` and `$value` keywords:

```javascript
var context = {
  'object':{
    'foo': 'bar',
    'value': 8
  }
};
```

As such...

```html
<!-- lego::foreach object -->
  <div><!-- lego::insert $key -->: <!-- lego::insert $value --></div>
<!-- lego::endforeach -->
```

Yields...

```html
<div>foo: bar</div>
<div>value: 8</div>
```

<p>&nbsp;</p>

<a name="if"></a>
### - If / Ifnot

The means of inserting logic into your templates, which comes in two flavors: a simple truthy comparison, or a direct comparison between two points of data.

Let's try a context / invocation as below:

```javascript
var context = {
  'word': 'hello',
  'verbs': []
};
```

```html
<!-- lego::if word -->
  <span><!-- lego::insert word --></span>
<!-- lego::endif -->

<!-- lego::if verbs -->
  <span><!-- lego::insert verbs --></span>
<!-- lego::endif -->
```

Yielding...

```html
<span>hello</span>
```

For truthy evaluations when using the simple `if` / `notif` conditionals, refer to the table below:

&nbsp; | Truthy | Not Truthy
:--- | :---: | :---:
Booleans | `true` | `false`
Arrays | length > 1 | length = 0
Objects | exists | `undefined`
Strings | length > 1 | length = 0
Numbers | < > 0 | = 0 

`notif` simply reverses the truthy state of any evaluation, useful for hiding pieces of HTML that have empty content.

<p>&nbsp;</p>

For more specific evaluations, you can use normal javascript comparisons as well:

```javascript
var context = {
  'word': 'hello',
  'verbs': ['a', 'b', 'c'],
  'length': 3
};
```

```html
<!-- lego::if verbs.length is length -->
  <span>Matches</span>
<!-- lego::endif -->

<!-- lego::if word !== 'world' -->
  <span>Does not match</span>
<!-- lego::endif -->
```

Yielding...

```html
<span>Matches</span>
<span>Does not match</span>
```

Take special note that you can use coffeescript `is` and `isnt` terms in place of `===` and `!==`.

Currently, more complex multiple comparisons joined with `&&` or `||` aren't supported in a single lego tag. You can, however, nest multiple `if` / `notif` tags to achieve similar results, although such complex abstractions are better left to derived attributes in the context object itself.