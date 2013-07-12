eco = require "eco"
_   = require "underscore"

layout = """
  <body>
    <% console.log "layout" %>
    <% console.dir @ %>
    <% console.dir arguments %>
    <h1><%- @title %></h1>
    <%- do @ %>
  </body>
"""
lfn = eco.compile layout

data =
  title   : "Working Eco layout"
  name    : "Bob"
  layout  : lfn
  rextend : (obj, fn) -> _.extend fn, obj

template = """
  <%- @layout @rextend @, => %>
    <% console.log "template" %>
    <% console.dir @ %>
    <% console.dir arguments %>
    <p>Hello, <%= @name %>!</p>
  <% end %>
"""
tfn = eco.compile template

html = tfn data


console.log html
