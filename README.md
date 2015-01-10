# Lego

Hapi *( >= 8)* and Express *( >= 4 )* HTML templating for files with .html extension.

[Server Implentation](#setup)

[View Templating Methods](#methods)

___
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

Both the Hapi `view` and the Express `render` methods take a second, optional, object after the template name. This object is the content object used for any calls to Lego's `insert` method.

___
<a name="methods"></a>
## View Templating Methods


### Define

Define custom snippets of HTML inside templates to include with insert command

**Examples:**

This defines a context-less block of code to be inserted anywhere

```html
<!-- lego::define customTemplate -->
  <div class="someBlockClass"></div>
<!-- lego::enddefine -->

Which when inserted like this...

<!-- lego::insert customTemplate -->

Renders this...

<div class="someBlockClass"></div>
```
This defines a block of code with a context, who's context will only be resolved when actually inserted

```html
<!-- lego::define customTemplate -->
  <div class="<!-- lego::insert $this -->"></div>
<!-- lego::enddefine -->

When inserted inside a foreach call on an context that looks like {arr: [1, 2, 3]}...

<!-- lego::foreach arr -->
    <!-- lego::insert customTemplate -->
<!-- lego::endforeach -->

Renders this...

<div class="1"></div>
<div class="2"></div>
<div class="3"></div>
```

Be aware that using the `define` method essentially extends the context object fed to the `view`/`render` method with a new key matching the string provided. So it's possible to override any values in that object that have the same name.


### Foreach
