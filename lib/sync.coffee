_insert = require(__dirname + '/insert.coffee')
_if = require(__dirname + '/if.coffee')
_fe = require(__dirname + '/foreach.coffee')
_use = require(__dirname + '/use.coffee')
_ctx = require(__dirname + '/context.coffee')

_sync = {}

_sync.name = '_sync'

_sync.anyLength = ($) ->
  [_fe, _insert, _if, _use].some((i)->
    meth = i.findComments or i.findOpenComments
    meth($).length
  )

_sync.recurse = ($, ctx) ->
  _if.expandElses($, ctx)
  _fe.recurse($, ctx)
  _insert.recurse($, ctx)
  _if.recurse($, ctx)
  _use.recurse($, ctx)
  
  _sync.recurse($, ctx) if _sync.anyLength($)

for par in [_insert, _if, _fe, _use, _ctx]
  for ref in [_insert, _if, _fe, _use, _ctx, _sync]
    par[ref.name] = ref if par isnt ref

module.exports = _sync