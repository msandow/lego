# Lego

Hapi *( >= 8)* and Express *( >= 4 )* HTML templating for files with .html extension.

___

## Setup With Server

```javascript
var lego = require('lego');

//Hapi server implementation
var hapi = require('hapi');
var server = new hapi.Server();

lego.attach(server, 'path_to_my/templates/');

server.connection(
  port: 8000
);

//Express server implementation
var express = require('express');
var app = express();

lego.attach(app, 'path_to_my/templates/');

var server = app.listen(8000)
```

In both instances, ***'path_to_my/templates/'*** points to the directory where your HTML templates reside. When calling to render a view, the name of the view must directly map to an file with an .html extension of the same relative path inside this directory.

___

## Define

Define custom snippets of HTML inside templates to include with insert command

**Examples:**

This defines a context-less block of code to be inserted anywhere

```html
<!-- lego::define customTemplate -->
  <div class="someBlockClass"></div>
<!-- lego::enddefine -->
```

This defines a block of code with a context, who's context will only be resolved when actually inserted

```html
<!-- lego::define customTemplate -->
  <div class="<!-- lego::insert $this -->"></div>
<!-- lego::enddefine -->
```